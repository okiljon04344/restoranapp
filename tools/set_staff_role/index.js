// Grants or revokes a staff role (custom claim) for an existing Firebase Auth user.
//
// Usage:
//   export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
//   node index.js grant  admin   owner@example.com
//   node index.js grant  kitchen chef@example.com
//   node index.js revoke kitchen chef@example.com
//
// The service-account key must never be committed (see .gitignore).
import {initializeApp, applicationDefault} from 'firebase-admin/app';
import {getAuth} from 'firebase-admin/auth';

const ROLES = ['admin', 'kitchen'];
const [action, role, email] = process.argv.slice(2);

if (!['grant', 'revoke'].includes(action) || !ROLES.includes(role) || !email) {
  console.error('Usage: node index.js <grant|revoke> <admin|kitchen> <email>');
  process.exit(1);
}

initializeApp({credential: applicationDefault()});
const auth = getAuth();

try {
  const user = await auth.getUserByEmail(email);
  const claims = {...(user.customClaims ?? {})};
  if (action === 'grant') {
    claims[role] = true;
  } else {
    delete claims[role];
  }
  await auth.setCustomUserClaims(user.uid, claims);
  console.log(`${action}: ${role} -> ${email} (uid: ${user.uid})`);
  console.log('The user must sign in again (or refresh the ID token) to receive it.');
} catch (err) {
  console.error(`Failed: ${err.message}`);
  process.exit(1);
}
