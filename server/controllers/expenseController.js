import Expense from '../models/Expense.js';
import { validationResult } from 'express-validator';

// @desc    Create expense
// @route   POST /api/expenses
// @access  Private
export const createExpense = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array(),
      });
    }

    const expense = await Expense.create({
      ...req.body,
      userId: req.user._id,
    });

    res.status(201).json({
      success: true,
      message: 'Expense created successfully',
      data: {
        expense: {
          id: expense._id,
          title: expense.title,
          amount: expense.amount,
          category: expense.category,
          date: expense.date,
          description: expense.description,
          account: expense.account,
          source: expense.source,
          status: expense.status,
          createdAt: expense.createdAt,
          updatedAt: expense.updatedAt,
        },
      },
    });
  } catch (error) {
    console.error('Create expense error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// @desc    Get all expenses
// @route   GET /api/expenses
// @access  Private
export const getExpenses = async (req, res) => {
  try {
    const {
      startDate,
      endDate,
      category,
      status,
      page = 1,
      limit = 50,
    } = req.query;

    const query = { userId: req.user._id };

    // Date filter
    if (startDate || endDate) {
      query.date = {};
      if (startDate) {
        query.date.$gte = new Date(startDate);
      }
      if (endDate) {
        query.date.$lte = new Date(endDate);
      }
    }

    // Category filter
    if (category) {
      query.category = category;
    }

    // Status filter
    if (status) {
      query.status = status;
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const expenses = await Expense.find(query)
      .sort({ date: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Expense.countDocuments(query);

    res.status(200).json({
      success: true,
      data: {
        expenses: expenses.map((expense) => ({
          id: expense._id,
          title: expense.title,
          amount: expense.amount,
          category: expense.category,
          date: expense.date,
          description: expense.description,
          account: expense.account,
          source: expense.source,
          status: expense.status,
          createdAt: expense.createdAt,
          updatedAt: expense.updatedAt,
        })),
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / parseInt(limit)),
        },
      },
    });
  } catch (error) {
    console.error('Get expenses error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// @desc    Get expense by ID
// @route   GET /api/expenses/:id
// @access  Private
export const getExpenseById = async (req, res) => {
  try {
    const expense = await Expense.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!expense) {
      return res.status(404).json({
        success: false,
        message: 'Expense not found',
      });
    }

    res.status(200).json({
      success: true,
      data: {
        expense: {
          id: expense._id,
          title: expense.title,
          amount: expense.amount,
          category: expense.category,
          date: expense.date,
          description: expense.description,
          account: expense.account,
          source: expense.source,
          status: expense.status,
          createdAt: expense.createdAt,
          updatedAt: expense.updatedAt,
        },
      },
    });
  } catch (error) {
    console.error('Get expense error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// @desc    Update expense
// @route   PUT /api/expenses/:id
// @access  Private
export const updateExpense = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array(),
      });
    }

    const expense = await Expense.findOneAndUpdate(
      {
        _id: req.params.id,
        userId: req.user._id,
      },
      req.body,
      {
        new: true,
        runValidators: true,
      }
    );

    if (!expense) {
      return res.status(404).json({
        success: false,
        message: 'Expense not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Expense updated successfully',
      data: {
        expense: {
          id: expense._id,
          title: expense.title,
          amount: expense.amount,
          category: expense.category,
          date: expense.date,
          description: expense.description,
          account: expense.account,
          source: expense.source,
          status: expense.status,
          createdAt: expense.createdAt,
          updatedAt: expense.updatedAt,
        },
      },
    });
  } catch (error) {
    console.error('Update expense error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// @desc    Delete expense
// @route   DELETE /api/expenses/:id
// @access  Private
export const deleteExpense = async (req, res) => {
  try {
    const expense = await Expense.findOneAndDelete({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!expense) {
      return res.status(404).json({
        success: false,
        message: 'Expense not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Expense deleted successfully',
    });
  } catch (error) {
    console.error('Delete expense error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// @desc    Get expenses by category
// @route   GET /api/expenses/by-category
// @access  Private
export const getExpensesByCategory = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;

    const query = { userId: req.user._id };

    // Date filter
    if (startDate || endDate) {
      query.date = {};
      if (startDate) {
        query.date.$gte = new Date(startDate);
      }
      if (endDate) {
        query.date.$lte = new Date(endDate);
      }
    }

    // Aggregate expenses by category
    const categoryTotals = await Expense.aggregate([
      { $match: query },
      {
        $group: {
          _id: '$category',
          total: { $sum: '$amount' },
          count: { $sum: 1 },
        },
      },
      { $sort: { total: -1 } },
    ]);

    // Calculate overall total
    const overallTotal = categoryTotals.reduce(
      (sum, item) => sum + item.total,
      0,
    );

    // Format response with percentages
    const categories = categoryTotals.map((item) => ({
      category: item._id,
      total: item.total,
      count: item.count,
      percentage: overallTotal > 0 ? (item.total / overallTotal) * 100 : 0,
    }));

    res.status(200).json({
      success: true,
      data: {
        categories,
        total: overallTotal,
      },
    });
  } catch (error) {
    console.error('Get expenses by category error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// @desc    Bulk create expenses
// @route   POST /api/expenses/bulk
// @access  Private
export const bulkCreateExpenses = async (req, res) => {
  try {
    const { expenses } = req.body;

    if (!Array.isArray(expenses) || expenses.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Expenses array is required',
      });
    }

    const expensesWithUserId = expenses.map((expense) => ({
      ...expense,
      userId: req.user._id,
    }));

    const createdExpenses = await Expense.insertMany(expensesWithUserId);

    res.status(201).json({
      success: true,
      message: 'Expenses created successfully',
      data: {
        expenses: createdExpenses.map((expense) => ({
          id: expense._id,
          title: expense.title,
          amount: expense.amount,
          category: expense.category,
          date: expense.date,
          description: expense.description,
          account: expense.account,
          source: expense.source,
          status: expense.status,
        })),
        count: createdExpenses.length,
      },
    });
  } catch (error) {
    console.error('Bulk create expenses error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

