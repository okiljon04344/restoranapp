// Checks firestore.rules for the three roles (customer, kitchen, admin)
// against the Firestore emulator. Run with `npm test` in this directory
// (needs Node 20+ and Java 21+ for the emulator).
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc, deleteDoc, collection, query, where, getDocs, serverTimestamp, runTransaction, writeBatch } from 'firebase/firestore';
import { readFileSync } from 'node:fs';

const env = await initializeTestEnvironment({
  projectId: 'demo-restoran',
  firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'), host: '127.0.0.1', port: 8085 },
});
let failed = 0;
const check = async (name, p) => { try { await p; console.log('ok   ', name); } catch (e) { failed++; console.log('FAIL ', name, '-', e.message.split('\n')[0]); } };

await env.withSecurityRulesDisabled(async (ctx) => {
  const db = ctx.firestore();
  await setDoc(doc(db, 'admins/admin'), { role: 'admin' });
  await setDoc(doc(db, 'staff/cook'), { role: 'kitchen', email: 'cook@x.com' });
  await setDoc(doc(db, 'cafes/main_cafe/tables/table_1'), { number: 1, isActive: true });
  await setDoc(doc(db, 'cafes/main_cafe/tables/table_2'), { number: 2, isActive: false });
  await setDoc(doc(db, 'cafes/main_cafe/menuItems/tea'), { name: 'Tea', price: 5, outOfStock: false, isAvailable: true });
  await setDoc(doc(db, 'cafes/main_cafe/ingredients/rice'), { name: 'Rice', quantity: 1, unit: 'kg', minimumQuantity: 0 });
  await setDoc(doc(db, 'cafes/main_cafe/orders/o1'), { customerUid: 'alice', status: 'pending', tableNumber: 1, tableId: 'table_1', items: [{ menuItemId: 'tea', name: 'Tea', quantity: 1, price: 5 }], total: 5 });
  await setDoc(doc(db, 'cafes/main_cafe/orders/o2'), { customerUid: 'alice', status: 'preparing', tableNumber: 1, tableId: 'table_1', items: [], total: 5 });
  await setDoc(doc(db, 'cafes/main_cafe/calls/c1'), { customerUid: 'alice', status: 'pending', tableNumber: 1, tableId: 'table_1', type: 'staff' });
  await setDoc(doc(db, 'staffRequests/newbie'), { email: 'n@x.com' });
});

const anon = env.unauthenticatedContext().firestore();
const alice = env.authenticatedContext('alice', { firebase: { sign_in_provider: 'anonymous' } }).firestore();
const bob = env.authenticatedContext('bob').firestore();
const cook = env.authenticatedContext('cook', { email: 'cook@x.com' }).firestore();
const admin = env.authenticatedContext('admin', { email: 'admin@x.com' }).firestore();
const newbie = env.authenticatedContext('newbie2', { email: 'n2@x.com' }).firestore();
const O = 'cafes/main_cafe/orders', C = 'cafes/main_cafe';
const order = (uid, extra = {}) => ({ orderNumber: 'ORD-1', orderType: 'dine_in', tableId: 'table_1', tableNumber: 1, customerUid: uid, items: [{ menuItemId: 'tea', name: 'Tea', quantity: 1, price: 5 }], total: 5, status: 'pending', createdAt: serverTimestamp(), ...extra });

// public reads
await check('anon reads menu', assertSucceeds(getDoc(doc(anon, `${C}/menuItems/tea`))));
await check('anon reads table', assertSucceeds(getDoc(doc(anon, `${C}/tables/table_1`))));
await check('anon cannot read orders', assertFails(getDoc(doc(anon, `${O}/o1`))));
await check('anon cannot read ingredients', assertFails(getDoc(doc(anon, `${C}/ingredients/rice`))));
await check('anon cannot create order', assertFails(setDoc(doc(anon, `${O}/x0`), order('alice'))));
await check('anon cannot write menu', assertFails(setDoc(doc(anon, `${C}/menuItems/hack`), { name: 'x' })));
// customer orders
await check('customer creates own pending order', assertSucceeds(setDoc(doc(alice, `${O}/a1`), order('alice'))));
await check('customer cannot create for other uid', assertFails(setDoc(doc(alice, `${O}/a2`), order('bob'))));
await check('customer cannot create non-pending', assertFails(setDoc(doc(alice, `${O}/a3`), order('alice', { status: 'paid' }))));
await check('customer cannot order at disabled table', assertFails(setDoc(doc(alice, `${O}/a4`), order('alice', { tableId: 'table_2', tableNumber: 2 }))));
await check('customer cannot order at unknown table', assertFails(setDoc(doc(alice, `${O}/a5`), order('alice', { tableId: 'table_9', tableNumber: 9 }))));
await check('customer cannot mismatch table id/number', assertFails(setDoc(doc(alice, `${O}/a6`), order('alice', { tableNumber: 7 }))));
await check('customer cannot add extra fields', assertFails(setDoc(doc(alice, `${O}/a7`), order('alice', { paidAt: serverTimestamp() }))));
await check('customer cannot send empty items', assertFails(setDoc(doc(alice, `${O}/a8`), order('alice', { items: [] }))));
await check('customer reads own order', assertSucceeds(getDoc(doc(alice, `${O}/o1`))));
await check('customer queries own orders', assertSucceeds(getDocs(query(collection(alice, O), where('customerUid', '==', 'alice')))));
await check('customer cannot list all orders', assertFails(getDocs(collection(alice, O))));
await check('other customer cannot read order', assertFails(getDoc(doc(bob, `${O}/o1`))));
await check('other customer cannot cancel order', assertFails(updateDoc(doc(bob, `${O}/o1`), { status: 'cancelled', updatedAt: serverTimestamp() })));
await check('customer cannot mark own order paid', assertFails(updateDoc(doc(alice, `${O}/o1`), { status: 'paid', updatedAt: serverTimestamp() })));
await check('customer cannot change total', assertFails(updateDoc(doc(alice, `${O}/o1`), { status: 'cancelled', total: 0 })));
await check('customer cannot cancel preparing order', assertFails(updateDoc(doc(alice, `${O}/o2`), { status: 'cancelled', updatedAt: serverTimestamp() })));
await check('customer cancels own pending order (transaction, as the app does)', assertSucceeds(runTransaction(alice, async (tx) => { const s = await tx.get(doc(alice, `${O}/o1`)); tx.update(s.ref, { status: 'cancelled', updatedAt: serverTimestamp() }); })));
await check('customer cannot delete order', assertFails(deleteDoc(doc(alice, `${O}/o1`))));
await check('customer cannot write ingredients', assertFails(updateDoc(doc(alice, `${C}/ingredients/rice`), { quantity: 99 })));
await check('customer cannot flip outOfStock', assertFails(updateDoc(doc(alice, `${C}/menuItems/tea`), { outOfStock: true })));
await check('customer cannot create table', assertFails(setDoc(doc(alice, `${C}/tables/table_5`), { number: 5, isActive: true })));
// calls
const call = (uid, extra = {}) => ({ tableId: 'table_1', tableNumber: 1, customerUid: uid, type: 'staff', status: 'pending', createdAt: serverTimestamp(), ...extra });
await check('customer creates call', assertSucceeds(setDoc(doc(alice, `${C}/calls/k1`), call('alice'))));
await check('customer creates bill request', assertSucceeds(setDoc(doc(alice, `${C}/calls/k2`), call('alice', { type: 'bill' }))));
await check('customer cannot call for disabled table', assertFails(setDoc(doc(alice, `${C}/calls/k3`), call('alice', { tableId: 'table_2', tableNumber: 2 }))));
await check('customer cannot read calls', assertFails(getDoc(doc(alice, `${C}/calls/c1`))));
await check('customer cannot resolve calls', assertFails(updateDoc(doc(alice, `${C}/calls/c1`), { status: 'resolved' })));
// kitchen
await check('kitchen lists active orders', assertSucceeds(getDocs(query(collection(cook, O), where('status', 'in', ['pending', 'preparing', 'ready', 'served'])))));
await check('kitchen accepts order + moves stock + flags menu (transaction)', assertSucceeds(runTransaction(cook, async (tx) => {
  const o = await tx.get(doc(cook, `${O}/a1`)); await tx.get(doc(cook, `${C}/menuItems/tea`)); await tx.get(doc(cook, `${C}/ingredients/rice`));
  tx.update(doc(cook, `${C}/ingredients/rice`), { quantity: 0.5, lastUpdated: serverTimestamp() });
  tx.update(doc(cook, `${C}/menuItems/tea`), { outOfStock: true, updatedAt: serverTimestamp() });
  tx.update(o.ref, { status: 'preparing', items: [], total: 5, stockDeductions: { rice: 0.5 }, updatedAt: serverTimestamp() });
})));
await check('kitchen closes bill (batch)', assertSucceeds((() => { const b = writeBatch(cook); b.update(doc(cook, `${O}/o2`), { status: 'paid', paidAt: serverTimestamp(), updatedAt: serverTimestamp() }); return b.commit(); })()));
await check('kitchen resolves call', assertSucceeds(updateDoc(doc(cook, `${C}/calls/c1`), { status: 'resolved', resolvedAt: serverTimestamp() })));
await check('kitchen reads calls', assertSucceeds(getDocs(query(collection(cook, `${C}/calls`), where('status', '==', 'pending')))));
await check('kitchen cannot rename ingredient', assertFails(updateDoc(doc(cook, `${C}/ingredients/rice`), { name: 'x' })));
await check('kitchen cannot set negative stock', assertFails(updateDoc(doc(cook, `${C}/ingredients/rice`), { quantity: -1 })));
await check('kitchen cannot change menu price', assertFails(updateDoc(doc(cook, `${C}/menuItems/tea`), { price: 1 })));
await check('kitchen cannot create menu item', assertFails(setDoc(doc(cook, `${C}/menuItems/new`), { name: 'x' })));
await check('kitchen cannot create table', assertFails(setDoc(doc(cook, `${C}/tables/table_6`), { number: 6, isActive: true })));
await check('kitchen cannot delete order', assertFails(deleteDoc(doc(cook, `${O}/o2`))));
await check('kitchen cannot grant staff', assertFails(setDoc(doc(cook, 'staff/bob'), { role: 'kitchen' })));
await check('kitchen reads own staff doc (role check)', assertSucceeds(getDoc(doc(cook, 'staff/cook'))));
await check('kitchen reads own (missing) admin doc (role check)', assertSucceeds(getDoc(doc(cook, 'admins/cook'))));
await check('kitchen cannot list staff requests', assertFails(getDocs(collection(cook, 'staffRequests'))));
// staff requests
await check('new account files its own request', assertSucceeds(setDoc(doc(newbie, 'staffRequests/newbie2'), { email: 'n2@x.com', createdAt: serverTimestamp() })));
await check('request with someone else\'s email is refused', assertFails(setDoc(doc(bob, 'staffRequests/bob'), { email: 'boss@x.com', createdAt: serverTimestamp() })));
await check('anonymous customer cannot file a request', assertFails(setDoc(doc(alice, 'staffRequests/alice'), { email: 'a@x.com', createdAt: serverTimestamp() })));
await check('nobody can self-grant staff', assertFails(setDoc(doc(newbie, 'staff/newbie2'), { role: 'kitchen' })));
await check('nobody can self-grant admin', assertFails(setDoc(doc(newbie, 'admins/newbie2'), { role: 'admin' })));
await check('admin cannot write admins from the client', assertFails(setDoc(doc(admin, 'admins/bob'), {})));
// admin
await check('admin lists requests', assertSucceeds(getDocs(collection(admin, 'staffRequests'))));
await check('admin approves request (batch)', assertSucceeds((() => { const b = writeBatch(admin); b.set(doc(admin, 'staff/newbie2'), { email: 'n2@x.com', role: 'kitchen', createdAt: serverTimestamp() }); b.delete(doc(admin, 'staffRequests/newbie2')); return b.commit(); })()));
await check('admin lists staff', assertSucceeds(getDocs(collection(admin, 'staff'))));
await check('admin revokes staff', assertSucceeds(deleteDoc(doc(admin, 'staff/newbie2'))));
await check('admin creates table', assertSucceeds(setDoc(doc(admin, `${C}/tables/table_3`), { number: 3, name: '', isActive: true, createdAt: serverTimestamp() })));
await check('admin edits menu', assertSucceeds(setDoc(doc(admin, `${C}/menuItems/plov`), { name: 'Plov', price: 30 })));
await check('admin edits ingredient', assertSucceeds(updateDoc(doc(admin, `${C}/ingredients/rice`), { name: 'Rice', unit: 'kg', quantity: 10, minimumQuantity: 2, lastUpdated: serverTimestamp() })));
await check('admin creates category', assertSucceeds(setDoc(doc(admin, `${C}/categories/c`), { name: 'Main' })));
await check('admin reads recent orders', assertSucceeds(getDocs(query(collection(admin, O), where('createdAt', '>=', new Date(0))))));
await check('admin queries table orders', assertSucceeds(getDocs(query(collection(admin, O), where('tableNumber', '==', 1)))));

await env.cleanup();
console.log(failed === 0 ? '\nALL RULE CHECKS PASSED' : `\n${failed} RULE CHECKS FAILED`);
process.exit(failed === 0 ? 0 : 1);
