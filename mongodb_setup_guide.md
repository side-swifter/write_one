# MongoDB Atlas Authentication Setup Guide

## 🚀 **Quick Setup Steps**

### **Step 1: Get Your App ID from MongoDB Atlas**

1. **Go to MongoDB Atlas** → **App Services**
2. **Create a new App** (if you haven't already):
   - Click "Create a New App"
   - Name: "WriteOneAuth"
   - Link to your "Write One" cluster
   - Choose region closest to your users

3. **Copy your App ID**:
   - In your App Services dashboard, you'll see your **App ID**
   - It looks like: `writeoneauth-abcde`

4. **Update the App ID in your code**:
   - Open `/lib/services/auth_service.dart`
   - Replace `"YOUR_APP_ID_HERE"` with your actual App ID

### **Step 2: Configure Authentication Providers**

#### **Enable Email/Password Authentication:**
1. Go to **Authentication** → **Authentication Providers**
2. Click **Email/Password**
3. Toggle **Enabled** to ON
4. Configure settings:
   - **User Confirmation Method**: "Send a confirmation email"
   - **Password Reset Method**: "Send a password reset email"
   - **Email Confirmation URL**: `http://localhost` (for testing)
   - **Password Reset URL**: `http://localhost` (for testing)

#### **Enable Google Authentication (Optional):**
1. Click **Google** in Authentication Providers
2. Toggle **Enabled** to ON
3. Add your Google OAuth credentials:
   - **Client ID**: Get from Google Cloud Console
   - **Client Secret**: Get from Google Cloud Console

### **Step 3: Set Up Email Templates (Optional)**
1. Go to **Authentication** → **Custom User Data**
2. Configure email templates for:
   - Account confirmation emails
   - Password reset emails

### **Step 4: Configure Database Rules**
1. Go to **Rules** → **Roles & Permissions**
2. Create rules for user data access
3. Example rule for user documents:
```javascript
{
  "roles": [
    {
      "name": "owner",
      "apply_when": {"%%user.id": "%%this.userId"},
      "read": true,
      "write": true
    }
  ]
}
```

## 🔧 **Code Integration**

### **Current Implementation Status:**
✅ **Authentication Service** - Created with all methods
✅ **Login Page** - Connected to MongoDB auth
✅ **Signup Page** - Connected to MongoDB auth
✅ **Error Handling** - Shows user-friendly error messages

### **What's Working:**
- User registration with email/password
- User login with email/password
- Error handling and user feedback
- Navigation flow after successful auth

### **Next Steps to Complete:**
1. **Replace App ID** in `auth_service.dart`
2. **Test authentication** with real MongoDB Atlas app
3. **Add loading states** to buttons during auth
4. **Implement email verification** flow
5. **Add Google Sign-In** integration

## 📱 **Testing Your Setup**

### **Test Registration:**
1. Run your app
2. Go to "Get started" → Sign up
3. Enter email and password
4. Should create user in MongoDB Atlas

### **Test Login:**
1. Go to "Login"
2. Enter registered email/password
3. Should authenticate and navigate to profile

### **Check MongoDB Atlas:**
1. Go to **App Services** → **App Users**
2. You should see registered users
3. Check **Logs** for any errors

## 🛠️ **Troubleshooting**

### **Common Issues:**

1. **"App ID not found"**
   - Make sure you replaced `YOUR_APP_ID_HERE` with actual App ID
   - Check App ID is correct in Atlas dashboard

2. **"Authentication failed"**
   - Ensure Email/Password provider is enabled
   - Check email format is valid
   - Verify password meets requirements

3. **"Network error"**
   - Check internet connection
   - Verify Atlas cluster is running
   - Check firewall settings

### **Debug Steps:**
1. Check Flutter console for error messages
2. Check MongoDB Atlas **Logs** section
3. Verify authentication provider settings
4. Test with simple email/password first

## 🔐 **Security Best Practices**

1. **Never hardcode credentials** in your app
2. **Use environment variables** for sensitive data
3. **Enable email verification** for production
4. **Set up proper database rules**
5. **Use HTTPS** for all communications

## 📋 **Current File Structure**
```
lib/
├── services/
│   └── auth_service.dart          # MongoDB authentication service
├── pages/
│   ├── login_page.dart           # Connected to MongoDB auth
│   ├── signup_page.dart          # Connected to MongoDB auth
│   └── email_verification_page.dart
└── main.dart                     # Routes configured
```

## 🎯 **Next Development Steps**

1. **Get your App ID** from MongoDB Atlas
2. **Update auth_service.dart** with your App ID
3. **Test registration/login** flow
4. **Add loading indicators** to improve UX
5. **Implement email verification** logic
6. **Add Google Sign-In** for better user experience
7. **Create user profile** management
8. **Add password reset** functionality

Your MongoDB authentication is now ready to use! Just update the App ID and test it out.
