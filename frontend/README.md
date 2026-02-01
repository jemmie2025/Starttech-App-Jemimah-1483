# StartTech Frontend (MuchToDo UI)

React + TypeScript frontend for the StartTech / MuchToDo application, built with Vite.

It provides the user-facing experience for:
- User registration and login
- Profile management
- Password change
- Todo/task management
- Health/status views

---

## Tech Stack

- React 18
- TypeScript
- Vite
- TanStack Router
- Axios (API client)

---

## Getting Started

From the project root:

```bash
cd frontend
npm install
npm run dev
```

Then open:

```text
http://localhost:5173
```

The dev server will proxy all API calls directly to whatever `VITE_API_BASE_URL` is configured for this environment.

---

## Environment Variables

Environment is configured via a `.env` file in this directory.

Key variable:

- `VITE_API_BASE_URL` – Base URL of the backend API.

Example (production, pointing at backend CloudFront):

```dotenv
VITE_API_BASE_URL=https://d2b1vhoymeqvxy.cloudfront.net
```

When not set, the app falls back to `http://localhost:8080` for local development.

---

## Scripts

- `npm run dev` – Start local development server.
- `npm run build` – Build the production bundle into `dist/`.
- `npm run preview` – Preview the production build locally.

---

## Building and Deploying

1. Build the app:

   ```bash
   npm run build
   ```

2. The production assets are output to `dist/`.

3. For the current setup, these files are synced to an S3 bucket (e.g. `prod-frontend-816212136006`) and served via CloudFront. Example (from this folder, with AWS CLI configured):

   ```bash
   aws s3 sync dist s3://prod-frontend-816212136006 --delete
   ```

4. After upload, create a CloudFront invalidation for `/*` so users see the latest version.

---

## Testing

Run frontend tests (if configured):

```bash
npm test
```

---

## Folder Structure (key paths)

- `src/` – Application source code
  - `routes/` – Route components (login, register, todos, profile, health, etc.)
  - `components/` – Shared UI components
  - `context/` – Auth context
  - `lib/apiClient.ts` – Axios instance configured with `VITE_API_BASE_URL`

