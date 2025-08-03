# README

## Development

- Start app: `./bin/dev`

### Credentials
- `EDITOR="vim" rails credentials:edit`

## Setup

### Prerequisites

- Ruby 3.0+
- Rails 8.0+

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   ```

4. Configure credentials:
   ```bash
   EDITOR="code --wait" bin/rails credentials:edit
   ```
   
   Add your Google Cloud configuration:
   ```yaml
   google_cloud:
     project_id: "your-google-cloud-project-id"
     location: "us-central1"
   ```

5. Set up Google Cloud authentication:
   ```bash
   # Set your Google Cloud credentials
   export GOOGLE_APPLICATION_CREDENTIALS="path/to/your/service-account-key.json"
   ```

### ⚠️ Platform-Specific Note: Tailwind Oxide Dependency

This project uses Tailwind CSS, which relies on a native binary called `oxide` for fast builds. The required oxide binary is **platform-specific**:

- **Local Development (macOS/ARM, Apple Silicon):**
  - The Linux-only oxide dependency (`@tailwindcss/oxide-linux-x64-gnu`) is **not** installed locally to avoid platform errors.
  - You can run all local builds and tests without this dependency.

- **Production/Docker (Linux/amd64):**
  - The Dockerfile explicitly installs `@tailwindcss/oxide-linux-x64-gnu` during the build process, ensuring the correct binary is present for production builds.
  - This means Docker builds and runs will work as expected, even if your local environment is macOS/ARM.

**You do not need to manually install or manage the oxide dependency for your local machine.**
