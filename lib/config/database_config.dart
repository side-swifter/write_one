class DatabaseConfig {
  // MongoDB Atlas (Cloud) Configuration
  // Your actual MongoDB Atlas connection string
  static const String mongoAtlasConnectionString = 
    'mongodb+srv://sideswifter2010_db_user:Ilovemongo2016@writeonedb.o23bjjx.mongodb.net/writeone?retryWrites=true&w=majority&appName=WriteOneDB';
  
  static const String databaseName = 'writeone';
  static const String imagesCollection = 'user_images';
  
  // Use Atlas connection string
  static String get connectionString => mongoAtlasConnectionString;
  
  // Instructions to get your connection string:
  // 1. Go to https://mongodb.com/atlas
  // 2. Create free account and cluster
  // 3. Click "Connect" -> "Connect your application"
  // 4. Copy the connection string and replace above
  // 5. Replace YOUR_USERNAME and YOUR_PASSWORD with your credentials
}
