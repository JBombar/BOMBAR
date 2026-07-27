# Security policy

## Supported version

The latest tagged release receives security fixes.

## Reporting

Do not open a public issue containing an exploitable weakness, secret, private repository detail, or client data. Contact the maintainer privately through the security-reporting channel listed on the published repository profile.

## Trust model

BOMBAR executes project-configured shell gates and a user-selected coding-agent adapter. Both are trusted local configuration and can execute arbitrary commands with the invoking user's permissions. Review them before running.

The default generic adapter is deliberately inert. BOMBAR does not silently discover credentials, bypass model permissions, authorize live actions, deploy, publish, or send messages.

For higher-risk brownfield work, run Builder sessions inside an external sandbox/container and protect CI/workflow configuration server-side. BOMBAR v0.1 provides orchestration controls; it is not itself an operating-system sandbox.
