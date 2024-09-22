const express = require('express');
const router = express.Router();
const blogPostController = require('../controllers/blogPost');
const { ensureAuthenticated } = require('../config/auth');

router.route('/')
  .get(blogPostController.getBlogPosts)
  .post(ensureAuthenticated, blogPostController.postNewBlogPost);

router.route('/new')
  .get(ensureAuthenticated, blogPostController.getNewBlogPost);

router.route('/:id/edit')
  .get(ensureAuthenticated, blogPostController.getEditBlogPost)
  .post(ensureAuthenticated, blogPostController.postEditBlogPost);

router.route('/:id/delete')
  .post(ensureAuthenticated, blogPostController.postDeleteBlogPost);

module.exports = router;