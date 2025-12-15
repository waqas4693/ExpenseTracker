import express from 'express';
import { body } from 'express-validator';
import {
  signUp,
  signIn,
  getMe,
  refreshToken,
} from '../controllers/authController.js';
import { protect } from '../middleware/authMiddleware.js';

const router = express.Router();

// Validation rules
const signUpValidation = [
  body('email').isEmail().withMessage('Please provide a valid email'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters'),
  body('name').notEmpty().withMessage('Name is required'),
];

const signInValidation = [
  body('email').isEmail().withMessage('Please provide a valid email'),
  body('password').notEmpty().withMessage('Password is required'),
];

// Routes
router.post('/signup', signUpValidation, signUp);
router.post('/login', signInValidation, signIn);
router.post('/refresh', refreshToken);
router.get('/me', protect, getMe);

export default router;

