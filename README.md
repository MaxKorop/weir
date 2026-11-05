# Weir

Weir is a monorepo for a financial application built from a small set of services and clients: a NestJS backend split into microservices, a React web app, a React Native mobile app and a shared UI library.

> The project is in an early stage. The apps are currently scaffolds that are wired together and ready for feature work.

## Tech stack

| Area | Tools |
| --- | --- |
| Monorepo | [pnpm](https://pnpm.io) workspaces, [Turborepo](https://turborepo.com) |
| Backend | [NestJS](https://nestjs.com), PostgreSQL, Redis |
| Web | React 19, Vite, TanStack Router / Query / Table, Tailwind CSS 4 |
| Mobile | React Native 0.88 with [Expo](https://expo.dev) |
| Shared UI | React components with Storybook, Radix UI, class-variance-authority |
| Tooling | TypeScript, ESLint, Husky, commitlint, lint-staged, Docker |

## Project structure

```
weir/
├── apps/
│   ├── api-gateway/        NestJS entry point for clients (port 3000)
│   ├── user-svc/           NestJS user microservice (port 3002)
│   ├── transaction-svc/    NestJS transaction microservice (port 3003)
│   ├── web/                React web app (Vite, port 5173)
│   └── mobile/             React Native app (Expo)
├── packages/
│   └── ui/                 Shared React component library (@weir/ui) + Storybook
├── scripts/                Git workflow helpers (branch name lint, commit tagging)
├── docs/                   Design references
├── .github/                Issue / PR templates and CI workflows
├── .husky/                 Git hooks
├── docker-compose.yml      Local PostgreSQL (x2) and Redis
├── Dockerfile              Production image for the api-gateway
├── turbo.json              Turborepo task pipeline
├── pnpm-workspace.yaml     Workspace definition
└── workflow.config.json    Branch types and issue tag prefix (`wr#`)
```

## Prerequisites

- **Node.js** 24.14.0 (see `.nvmrc`; with nvm run `nvm use`)
- **pnpm** 12.4.2, pinned in `package.json`. Enable it with `corepack enable`
- **Docker** for the local databases and Redis
- For mobile: Xcode (iOS Simulator) and/or Android Studio (emulator), or the Expo Go app on a phone

## Setup

```bash
git clone git@github.com:MaxKorop/weir.git
cd weir
pnpm install
cp .env.example .env
docker compose up -d
```

`pnpm install` also installs the Git hooks (Husky). `docker compose up -d` starts two PostgreSQL databases (ports 5432 and 5433) and Redis (port 6379). Connection strings are in `.env.example`.

## Running the project

Each app is started on its own (`pnpm dev` only runs apps that define a `dev` script, which is currently just the web app):

| App | Command | URL |
| --- | --- | --- |
| Web | `pnpm --filter web dev` | http://localhost:5173 |
| API gateway | `pnpm --filter api-gateway start:dev` | http://localhost:3000 |
| User service | `pnpm --filter user-svc start:dev` | http://localhost:3002 |
| Transaction service | `pnpm --filter transaction-svc start:dev` | http://localhost:3003 |
| Mobile | `pnpm --filter mobile start` | Press `i` (iOS), `a` (Android) or scan the QR code with Expo Go |
| UI Storybook | `pnpm --filter @weir/ui storybook` | http://localhost:6006 |

Service ports can be changed with the `PORT` environment variable.

## Useful commands

| Command | What it does |
| --- | --- |
| `pnpm build` | Build every package through Turborepo |
| `pnpm lint` | Lint every package |
| `pnpm lint:branch` | Check the current branch name against the project rules |
| `pnpm --filter <name> <script>` | Run a script in one workspace |
| `pnpm --filter <name> add <package>` | Add a dependency to one workspace |

In the mobile app, install Expo-compatible dependency versions with `pnpm --filter mobile exec expo install <package>`.

## Contributing

Work is tracked in GitHub issues, and every branch and commit references one.

- **Branch name:** `<type>/<issue-number>-<short-name>`, e.g. `feat/12-login-flow`. Types: `feat`, `fix`, `chore`, `refactor`, `docs`, `style`, `perf`, `test`, `build`, `ci`, `revert`.
- **Commit message:** [Conventional Commits](https://www.conventionalcommits.org) ending with the issue tag, e.g. `feat: add login flow wr#12`.
- **Pull request:** use the PR template, title in the same commit format, and write `Closes #<issue-number>` so the issue closes on merge.

Git hooks check commit messages and branch names locally, and CI checks the PR title and branch name.

## License

[GNU GPL v3](LICENSE)
