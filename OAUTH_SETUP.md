# Google OAuth Setup for ZenMail

This guide will help you set up Google OAuth for basic authentication in ZenMail.

## What's Already Configured

✅ **OAuth Configuration** (`config/initializers/omniauth.rb`):
- Google OAuth with Gmail API scopes
- Includes `access_type: "offline"` for refresh tokens
- Scopes: `email`, `profile`, `gmail.readonly`, `gmail.modify`

✅ **OAuth Callback** (`app/controllers/omniauth_callbacks_controller.rb`):
- Handles Google OAuth callback
- Stores tokens in existing user fields
- Creates or updates users based on OAuth response

✅ **Sign-in Page** (`app/views/sessions/new.html.erb`):
- Already has "Sign in with Google" button

✅ **Database Schema**:
- Uses existing fields: `access_token`, `refresh_token`, `token_expires_at`

## Setup Steps

### 1. Create Google OAuth Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the Gmail API:
   - Go to "APIs & Services" > "Library"
   - Search for "Gmail API"
   - Click "Enable"

4. Create OAuth 2.0 credentials:
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "OAuth 2.0 Client IDs"
   - Choose "Web application"
   - Add authorized redirect URIs:
     - Development: `http://localhost:3000/auth/google_oauth2/callback`
     - Production: `https://yourdomain.com/auth/google_oauth2/callback`

### 2. Configure Rails Credentials

```bash
VISUAL="vim" bin/rails credentials:edit
```

Add your Google OAuth credentials:
```yaml
google_oauth:
  client_id: "your-client-id-here"
  client_secret: "your-client-secret-here"
```

### 3. Test the OAuth Flow

1. Start your Rails server:
   ```bash
   bin/rails server
   ```

2. Go to `http://localhost:3000/sign-in`

3. Click "Sign in with Google"

4. Complete the OAuth flow

5. Verify you're redirected to dashboard with success message

## Verification

After successful OAuth, check that:
- User is created/updated in database
- `access_token`, `refresh_token`, `token_expires_at` are stored
- User is signed in and redirected to dashboard

## Troubleshooting

- **"Invalid redirect URI"**: Check that redirect URI in Google Cloud Console matches exactly
- **"Access blocked"**: Make sure Gmail API is enabled in your Google Cloud project
- **"Invalid client"**: Verify Client ID and Secret are correct in credentials

## Next Steps

Once OAuth is working, you can:
1. Test token refresh functionality
2. Add Gmail API integration
3. Implement email features
4. Add Outlook OAuth support 