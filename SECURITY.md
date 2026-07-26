# Security policy

## Security model

Auto Market Global treats the Flutter client as untrusted. Access control is
enforced by Firebase Authentication, Cloud Firestore rules, and Cloud Storage
rules. Hiding a button in the interface is never considered authorization.

The current rules enforce these core guarantees:

- blocked accounts cannot change profiles, listings, favorites, chats, or
  complaints;
- users cannot change their own role, block status, verification status, or
  administrative permissions;
- only active owners can modify their listings;
- chat access is limited to active conversation participants;
- messages and audit records are immutable after creation;
- administrative actions require an active admin account and the appropriate
  permission;
- uploaded listing images are restricted by owner, path, size, MIME type, and
  safe filename.

## Deployment checklist

Before every release:

1. Run `flutter pub get`, `flutter analyze`, and `flutter test`.
2. Review changes to `firestore.rules`, `storage.rules`, and
   `firestore.indexes.json`.
3. Deploy rules before publishing a client that depends on them.
4. Test a regular user, a blocked user, an admin, and a super admin.
5. Enable Firebase App Check for every production platform.
6. Require MFA for project owners and administrators.
7. Keep billing alerts, audit logging, and recovery access configured.

## Reporting a vulnerability

Do not publish credentials, user data, or exploit details in a public issue.
Contact the project owner privately and include the affected feature, exact
reproduction steps, and observed impact.
