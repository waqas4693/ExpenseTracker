import app from './app.js';

// Export for Vercel serverless function
export default app;

// Start server if running locally (not on Vercel)
if (process.env.VERCEL !== '1') {
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});
}

