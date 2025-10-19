const express = require('express');
const expressLayouts = require('express-ejs-layouts');
const path = require('path');
const i18n = require('i18n');
const app = express();
const port = 3125;

// i18n yapılandırması
i18n.configure({
    locales: ['tr', 'en'],
    directory: path.join(__dirname, 'locales'),
    defaultLocale: 'tr',
    cookie: 'lang',
    queryParameter: 'lang',
    autoReload: true,
    syncFiles: true
});

// View engine ayarları
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.set('layout', 'layout');

// Middleware
app.use(i18n.init);
app.use(expressLayouts);
app.use(express.static('public'));

// Dil değiştirme route'u
app.get('/lang/:locale', (req, res) => {
    const locale = req.params.locale;
    if (['tr', 'en'].includes(locale)) {
        res.cookie('lang', locale);
        res.redirect('back');
    } else {
        res.redirect('/');
    }
});

// Routes
app.get('/', (req, res) => {
    res.locals.currentLocale = res.getLocale();
    res.render('home', { page: 'home', __: res.__ });
});

app.get('/experience', (req, res) => {
    res.locals.currentLocale = res.getLocale();
    res.render('experience', { page: 'experience', __: res.__ });
});

app.get('/education', (req, res) => {
    res.locals.currentLocale = res.getLocale();
    res.render('education', { page: 'education', __: res.__ });
});

app.get('/skills', (req, res) => {
    res.locals.currentLocale = res.getLocale();
    res.render('skills', { page: 'skills', __: res.__ });
});

app.get('/contact', (req, res) => {
    res.locals.currentLocale = res.getLocale();
    res.render('contact', { page: 'contact', __: res.__ });
});

app.get('/projects', (req, res) => {
    res.locals.currentLocale = res.getLocale();
    res.render('projects', { page: 'projects', __: res.__ });
});

app.get('/articles', (req, res) => {
    res.locals.currentLocale = res.getLocale();
    res.render('articles', { page: 'articles', __: res.__ });
});

app.get('/certificates', (req, res) => {
    res.locals.currentLocale = res.getLocale();
    res.render('certificates', { page: 'certificates', __: res.__ });
});

app.listen(port, () => {
    console.log(`Portfolyo sitesi http://localhost:${port} adresinde çalışıyor`);
}); 