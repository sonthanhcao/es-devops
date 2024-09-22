const BlogPost = require('../models/BlogPost');

/**
 * GET /blog
 * List all blog posts.
 */
exports.getBlogPosts = async (req, res) => {
  const blogPosts = await BlogPost.find().populate('author');
  res.render('blog/index', { title: 'Blog', blogPosts });
};

/**
 * GET /blog/new
 * Display form to create a new blog post.
 */
exports.getNewBlogPost = (req, res) => {
  res.render('blog/new', { title: 'New Blog Post', csrfToken: req.csrfToken() });
};

/**
 * POST /blog/new
 * Create a new blog post.
 */
exports.postNewBlogPost = async (req, res) => {
  const { title, content } = req.body;
  const blogPost = new BlogPost({
    title,
    content,
    author: req.user.id
  });
  await blogPost.save();
  res.redirect('/blog');
};

/**
 * GET /blog/:id/edit
 * Display form to edit a blog post.
 */
exports.getEditBlogPost = async (req, res) => {
  const blogPost = await BlogPost.findById(req.params.id);
  res.render('blog/edit', { title: 'Edit Blog Post', blogPost });
};

/**
 * POST /blog/:id/edit
 * Update a blog post.
 */
exports.postEditBlogPost = async (req, res) => {
  const { title, content } = req.body;
  await BlogPost.findByIdAndUpdate(req.params.id, { title, content, updatedAt: Date.now() });
  res.redirect('/blog');
};

/**
 * POST /blog/:id/delete
 * Delete a blog post.
 */
exports.postDeleteBlogPost = async (req, res) => {
  await BlogPost.findByIdAndDelete(req.params.id);
  res.redirect('/blog');
};