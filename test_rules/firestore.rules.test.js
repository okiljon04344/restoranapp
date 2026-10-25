// Verifies firestore.rules against the local emulator.
// Run: npm install && npm test
import {readFileSync} from 'node:fs';
import {after, before, beforeEach, describe, test} from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  addDoc,
  collection,
  doc,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
} from 'firebase/firestore';

const CAFE = 'cafes/main_cafe';
let env;

const guest = () => env.unauthenticatedContext().firestore();
const user = (claims = {}) => env.authenticatedContext('u1', claims).firestore();
const admin = () => env.authenticatedContext('admin1', {admin: true}).firestore();
const kitchen = () => env.authenticatedContext('chef1', {kitchen: true}).firestore();

const validOrder = (overrides = {}) => ({
  orderNumber: 'ORD-001',
  orderType: 'Dine-in',
  tableName: 'Table 3',
  tableNumber: 3,
  items: [{menuItemId: 'm1', name: 'Plov', quantity: 2, price: 1200}],
  total: 2400,
  status: 'pending',
  createdAt: Timestamp.now(),
  ...overrides,
});

async function seedOrder(id, status) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), `${CAFE}/orders/${id}`), validOrder({status}));
  });
}

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-restoranapp',
    firestore: {rules: readFileSync('../firestore.rules', 'utf8')},
  });
});
beforeEach(() => env.clearFirestore());
after(() => env.cleanup());

describe('admin role', () => {
  test('a user who merely registered admin@gmail.com is not an admin', async () => {
    const db = env
      .authenticatedContext('attacker', {email: 'admin@gmail.com', email_verified: false})
      .firestore();
    await assertFails(setDoc(doc(db, `${CAFE}/menuItems/m1`), {name: 'Free food', price: 0}));
  });

  test('admin claim can manage the menu and ingredients', async () => {
    await assertSucceeds(setDoc(doc(admin(), `${CAFE}/menuItems/m1`), {name: 'Plov', price: 1200}));
    await assertSucceeds(setDoc(doc(admin(), `${CAFE}/ingredients/i1`), {name: 'Rice', stock: 10}));
  });

  test('kitchen staff cannot edit the menu', async () => {
    await assertFails(setDoc(doc(kitchen(), `${CAFE}/menuItems/m1`), {name: 'Plov', price: 1}));
  });

  test('signed-in users without a role cannot write ingredients', async () => {
    await assertFails(setDoc(doc(user(), `${CAFE}/ingredients/i1`), {name: 'Rice'}));
  });
});

describe('orders', () => {
  test('guest can place a well-formed pending order', async () => {
    await assertSucceeds(addDoc(collection(guest(), `${CAFE}/orders`), validOrder()));
  });

  test('guest cannot place an order that is already completed', async () => {
    await assertFails(addDoc(collection(guest(), `${CAFE}/orders`), validOrder({status: 'completed'})));
  });

  test('guest cannot add unexpected fields', async () => {
    await assertFails(addDoc(collection(guest(), `${CAFE}/orders`), validOrder({paid: true})));
  });

  test('guest cannot send a negative total or zero quantity', async () => {
    await assertFails(addDoc(collection(guest(), `${CAFE}/orders`), validOrder({total: -1})));
    await assertFails(
      addDoc(
        collection(guest(), `${CAFE}/orders`),
        validOrder({items: [{menuItemId: 'm1', name: 'Plov', quantity: 0, price: 1200}]}),
      ),
    );
  });

  test('guest can cancel a pending order', async () => {
    await seedOrder('o1', 'pending');
    await assertSucceeds(updateDoc(doc(guest(), `${CAFE}/orders/o1`), {status: 'cancelled'}));
  });

  test('guest cannot cancel an order the kitchen already started', async () => {
    await seedOrder('o2', 'cooking');
    await assertFails(updateDoc(doc(guest(), `${CAFE}/orders/o2`), {status: 'cancelled'}));
  });

  test('guest cannot change the total of an order', async () => {
    await seedOrder('o3', 'pending');
    await assertFails(updateDoc(doc(guest(), `${CAFE}/orders/o3`), {status: 'cancelled', total: 0}));
  });

  test('kitchen staff can move an order forward', async () => {
    await seedOrder('o4', 'pending');
    await assertSucceeds(updateDoc(doc(kitchen(), `${CAFE}/orders/o4`), {status: 'cooking'}));
  });
});

describe('staff calls', () => {
  test('guest can call staff', async () => {
    await assertSucceeds(
      addDoc(collection(guest(), `${CAFE}/calls`), {
        tableNumber: 3,
        status: 'pending',
        createdAt: serverTimestamp(),
      }),
    );
  });

  test('guest cannot resolve a call', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), `${CAFE}/calls/c1`), {tableNumber: 3, status: 'pending'});
    });
    await assertFails(updateDoc(doc(guest(), `${CAFE}/calls/c1`), {status: 'resolved'}));
    await assertSucceeds(updateDoc(doc(admin(), `${CAFE}/calls/c1`), {status: 'resolved'}));
  });
});
