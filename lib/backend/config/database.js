const mongoose = require('mongoose');
require('dotenv').config();

const MONGO_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/checkdent';
const MAX_RETRIES = 3;
const RETRY_DELAY = 2000;

class Database {
  constructor() {
    this.isConnecting = false;
    this.connectionAttempts = 0;
  }

  async sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  async connect(retryCount = 0) {
    try {
      // If already connected, return
      if (mongoose.connection.readyState === 1) {
        return mongoose.connection;
      }

      // Prevent concurrent connection attempts
      if (this.isConnecting) {
        let waitCount = 0;
        while (this.isConnecting && waitCount < 50) {
          await this.sleep(100);
          waitCount++;
        }
        if (mongoose.connection.readyState === 1) {
          return mongoose.connection;
        }
      }

      this.isConnecting = true;
      console.log(`[DB] Connection attempt ${retryCount + 1}/${MAX_RETRIES}`);
      
      await mongoose.connect(MONGO_URI, {
        serverSelectionTimeoutMS: 15000,
        socketTimeoutMS: 30000,
        retryWrites: true,
        w: 'majority'
      });
      
      this.isConnecting = false;
      this.connectionAttempts = 0;
      
      console.log('✅ MongoDB connected successfully');
      console.log(`📊 Database URI: ${MONGO_URI}`);
      
      return mongoose.connection;
      
    } catch (error) {
      this.isConnecting = false;
      this.connectionAttempts++;
      
      console.error(`[DB] Connection error (attempt ${retryCount + 1}): ${error.message}`);
      
      if (retryCount < MAX_RETRIES - 1) {
        console.log(`[DB] Retrying in ${RETRY_DELAY}ms...`);
        await this.sleep(RETRY_DELAY);
        return this.connect(retryCount + 1);
      } else {
        const dbError = new Error(
          `Failed to connect to MongoDB after ${MAX_RETRIES} attempts.\n` +
          `URI: ${MONGO_URI}\n` +
          `Error: ${error.message}`
        );
        dbError.code = 'DB_CONNECTION_FAILED';
        dbError.statusCode = 503;
        throw dbError;
      }
    }
  }

  async disconnect() {
    try {
      if (mongoose.connection.readyState === 1) {
        await mongoose.disconnect();
        console.log('✅ MongoDB disconnected successfully');
      }
    } catch (error) {
      console.error('❌ Error disconnecting from database:', error.message);
    }
  }

  // MongoDB helper methods
  async findOne(modelName, filter = {}) {
    try {
      const Model = mongoose.model(modelName);
      return await Model.findOne(filter);
    } catch (error) {
      console.error('❌ Database query error:', error.message);
      const dbError = new Error(`Query error: ${error.message}`);
      dbError.code = 'DB_QUERY_ERROR';
      dbError.statusCode = 500;
      throw dbError;
    }
  }

  async find(modelName, filter = {}) {
    try {
      const Model = mongoose.model(modelName);
      return await Model.find(filter);
    } catch (error) {
      console.error('❌ Database query error:', error.message);
      const dbError = new Error(`Query error: ${error.message}`);
      dbError.code = 'DB_QUERY_ERROR';
      dbError.statusCode = 500;
      throw dbError;
    }
  }

  async create(modelName, data) {
    try {
      const Model = mongoose.model(modelName);
      return await Model.create(data);
    } catch (error) {
      console.error('❌ Database create error:', error.message);
      const dbError = new Error(`Create error: ${error.message}`);
      dbError.code = 'DB_CREATE_ERROR';
      dbError.statusCode = error.code === 11000 ? 409 : 500;
      throw dbError;
    }
  }

  async updateOne(modelName, filter, update) {
    try {
      const Model = mongoose.model(modelName);
      return await Model.updateOne(filter, update);
    } catch (error) {
      console.error('❌ Database update error:', error.message);
      const dbError = new Error(`Update error: ${error.message}`);
      dbError.code = 'DB_UPDATE_ERROR';
      dbError.statusCode = 500;
      throw dbError;
    }
  }

  async deleteOne(modelName, filter) {
    try {
      const Model = mongoose.model(modelName);
      return await Model.deleteOne(filter);
    } catch (error) {
      console.error('❌ Database delete error:', error.message);
      const dbError = new Error(`Delete error: ${error.message}`);
      dbError.code = 'DB_DELETE_ERROR';
      dbError.statusCode = 500;
      throw dbError;
    }
  }

  async getConnectionStatus() {
    try {
      const readyState = mongoose.connection.readyState;
      const states = {
        0: 'disconnected',
        1: 'connected',
        2: 'connecting',
        3: 'disconnecting'
      };

      return {
        connected: readyState === 1,
        state: states[readyState] || 'unknown',
        uri: MONGO_URI,
        attempts: this.connectionAttempts
      };
    } catch (error) {
      return {
        connected: false,
        reason: error.message,
        attempts: this.connectionAttempts
      };
    }
  }
}

// Create singleton instance
const database = new Database();

// Handle process termination
process.on('exit', () => database.disconnect());
process.on('SIGINT', async () => {
  await database.disconnect();
  process.exit(0);
});

module.exports = {
  database,
  mongoose
};