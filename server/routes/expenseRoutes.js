import express from 'express';
import { body } from 'express-validator';
import {
  createExpense,
  getExpenses,
  getExpenseById,
  updateExpense,
  deleteExpense,
  bulkCreateExpenses,
  getExpensesByCategory,
} from '../controllers/expenseController.js';
import { protect } from '../middleware/authMiddleware.js';

const router = express.Router();

// Validation rules
const expenseValidation = [
  body('title').notEmpty().withMessage('Title is required'),
  body('amount')
    .isFloat({ min: 0 })
    .withMessage('Amount must be a positive number'),
  body('category').notEmpty().withMessage('Category is required'),
  body('date').isISO8601().withMessage('Date must be a valid ISO 8601 date'),
];

// Routes
router.post('/', protect, expenseValidation, createExpense);
router.post('/bulk', protect, bulkCreateExpenses);
router.get('/by-category', protect, getExpensesByCategory);
router.get('/', protect, getExpenses);
router.get('/:id', protect, getExpenseById);
router.put('/:id', protect, expenseValidation, updateExpense);
router.delete('/:id', protect, deleteExpense);

export default router;

