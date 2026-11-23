# Validation

ShellCheck and the restore drill passed: the three-record fixture was backed up and restored, integrity was verified, an existing destination was refused, and a corrupted backup was rejected without creating a restore file.

## Coverage

Controlled SQLite fixtures with checksum and database integrity verification. Off-host storage, encryption, and recovery-time measurements are separate recovery exercises.
