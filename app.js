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
    res.render('pages/home', { page: 'home' });
});

app.get('/experience', (req, res) => {
    res.render('pages/experience', { page: 'experience' });
});

app.get('/education', (req, res) => {
    res.render('pages/education', { page: 'education' });
});

app.get('/skills', (req, res) => {
    res.render('pages/skills', { page: 'skills' });
});

app.get('/contact', (req, res) => {
    res.render('pages/contact', { page: 'contact' });
});

app.get('/projects', (req, res) => {
    res.render('pages/projects', { page: 'projects' });
});

app.listen(port, () => {
    console.log(`Portfolyo sitesi http://localhost:${port} adresinde çalışıyor`);
}); 