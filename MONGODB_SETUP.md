# MongoDB Atlas (Cloud) Setup for WriteOne Demo

## 🚀 Quick Setup Guide

### Step 1: Create MongoDB Atlas Account
1. Go to **[mongodb.com/atlas](https://mongodb.com/atlas)**
2. Click **"Try Free"**
3. Sign up with email or Google account
4. Choose **"Build a database"**

### Step 2: Create Free Cluster
1. Select **"M0 Sandbox"** (FREE tier)
2. Choose **AWS** and closest region
3. Name your cluster (e.g., "WriteOneCluster")
4. Click **"Create Cluster"** (takes 1-3 minutes)

### Step 3: Create Database User
1. Go to **"Database Access"** in left sidebar
2. Click **"Add New Database User"**
3. Choose **"Password"** authentication
4. Username: `writeone_user` (or your choice)
5. Password: Generate secure password (save it!)
6. Database User Privileges: **"Read and write to any database"**
7. Click **"Add User"**

### Step 4: Whitelist IP Address
1. Go to **"Network Access"** in left sidebar
2. Click **"Add IP Address"**
3. Click **"Allow Access from Anywhere"** (for demo)
   - Or add your specific IP for security
4. Click **"Confirm"**

### Step 5: Get Connection String
1. Go back to **"Database"** (Clusters)
2. Click **"Connect"** on your cluster
3. Choose **"Connect your application"**
4. Select **"Driver: Node.js"** and **"Version: 4.1 or later"**
5. Copy the connection string (looks like):
   ```
   mongodb+srv://writeone_user:<password>@writeone.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```

### Step 6: Update Your App Configuration
1. Open `lib/config/database_config.dart`
2. Replace the connection string:

```dart
static const String mongoAtlasConnectionString = 
  'mongodb+srv://writeone_user:YOUR_ACTUAL_PASSWORD@writeone.xxxxx.mongodb.net/writeone?retryWrites=true&w=majority';
```

**Replace:**
- `YOUR_ACTUAL_PASSWORD` with the password you created
- `writeone.xxxxx.mongodb.net` with your actual cluster URL

### Step 7: Test the Connection
1. Save the file
2. Hot restart your Flutter app
3. Take a photo or select from gallery
4. Check console logs for:
   ```
   ✅ Connected to MongoDB successfully
   🔄 Saving image to MongoDB for user: [user_id]
   ✅ Image saved to MongoDB with ID: [object_id]
   ```

## 📊 View Your Data

### Option 1: MongoDB Atlas Web Interface
1. Go to your Atlas dashboard
2. Click **"Browse Collections"**
3. You'll see your `writeone` database and `user_images` collection

### Option 2: MongoDB Compass (Desktop App)
1. Download from [mongodb.com/compass](https://mongodb.com/compass)
2. Use the same connection string to connect

## 🗄️ Database Structure

Your images will be stored as:
```json
{
  "_id": "ObjectId(...)",
  "userId": "supabase_user_id_or_demo_user",
  "originalName": "IMG_123.jpg",
  "contentType": "image/jpeg", 
  "uploadedAt": "2025-01-28T07:12:00.000Z",
  "fileSize": 2048576,
  "imageData": "base64_encoded_image...",
  "analysisStarted": "2025-01-28T07:12:00.000Z",
  "source": "camera_capture"
}
```

## ✅ That's It!

Your WriteOne app will now save all captured/selected images to MongoDB Atlas cloud database, organized by user ID from Supabase authentication.

## 🔧 Troubleshooting

**Connection fails?**
- Check your username/password in the connection string
- Verify IP address is whitelisted
- Make sure cluster is running (green status in Atlas)

**Images not saving?**
- Check Flutter console for error messages
- Verify Supabase authentication is working
- Test with a simple photo first
