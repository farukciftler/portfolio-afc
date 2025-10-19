const express = require('express');
const expressLayouts = require('express-ejs-layouts');
const path = require('path');
const fs = require('fs');
const cookieParser = require('cookie-parser');
const app = express();
const port = 3125;

// Basit çeviri sistemi
const translations = {
    tr: JSON.parse(fs.readFileSync(path.join(__dirname, 'locales/tr.json'), 'utf8')),
    en: JSON.parse(fs.readFileSync(path.join(__dirname, 'locales/en.json'), 'utf8'))
};

// Çeviri fonksiyonu
function __(key, locale = 'tr') {
    const keys = key.split('.');
    let value = translations[locale];

    for (const k of keys) {
        value = value && value[k];
    }

    return value || key;
}

// View engine ayarları
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.set('layout', 'layout');

// Middleware - Locale yönetimi
app.use((req, res, next) => {
    // Cookie'den veya query'den locale al
    let locale = req.cookies.lang || req.query.lang || 'tr';

    // Geçerli locale'ları kontrol et
    if (!['tr', 'en'].includes(locale)) {
        locale = 'tr';
    }

    // Çeviri fonksiyonunu res.locals'a ekle
    res.locals.__ = (key) => __(key, locale);
    res.locals.currentLocale = locale;
    res.getLocale = () => locale;

    next();
});

app.use(cookieParser());
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