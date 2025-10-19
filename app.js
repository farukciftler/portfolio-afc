const express = require('express');
const expressLayouts = require('express-ejs-layouts');
const path = require('path');
const app = express();
const port = 3125;

// View engine ayarları
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.set('layout', 'layout');

// Middleware
app.use(expressLayouts);
app.use(express.static('public'));

// Routes
app.get('/', (req, res) => {
    res.render('home', { page: 'home' });
});

app.get('/experience', (req, res) => {
    res.render('experience', { page: 'experience' });
});

app.get('/education', (req, res) => {
    res.render('education', { page: 'education' });
});

app.get('/skills', (req, res) => {
    res.render('skills', { page: 'skills' });
});

app.get('/contact', (req, res) => {
    res.render('contact', { page: 'contact' });
});

app.get('/projects', (req, res) => {
    res.render('projects', { page: 'projects' });
});

app.get('/articles', (req, res) => {
    res.render('articles', { page: 'articles' });
});

app.get('/certificates', (req, res) => {
    res.render('certificates', { page: 'certificates' });
});

app.listen(port, () => {
    console.log(`Portfolyo sitesi http://localhost:${port} adresinde çalışıyor`);
}); 