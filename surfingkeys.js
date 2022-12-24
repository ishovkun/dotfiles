// an example to create a new mapping ctrl-y
mapkey('<Ctrl-y>', 'Show me the money', function() {
    Front.showPopup('a well-known phrase uttered by characters in the 1996 film Jerry Maguire (Escape to close).');
});

// an example to replace u with ?, click Default mappings to see how u works.
// map('?', 'u');
// map('gt', 'T');
map('o', 'go');
map('J', 'R');
map('K', 'E');
// mapkey('<F3>', '#3Go one tab left', 'RUNTIME("previousTab")');
// mapkey('<F4>', '#3Go one tab right', 'RUNTIME("nextTab")');
map('F', 'af');
map('u', 'X');
map('H', 'S');

unmap('=');
map('=', 'zi');
map('-', 'zo');
// map('=', '<Ctrl-=>');

map('<F2>', '<Ctrl-t>');
// an example to remove mapkey Ctrl-i
unmap('<Ctrl-i>');

addSearchAlias('cd', 'cambrige dictionary', 'http://dictionary.cambridge.org/search/american-english/direct/?source=gadgets&q=');
addSearchAlias('kino', 'kinopoisk', 'http://www.kinopoisk.ru/index.php?first=no&what=&kp_query=');
addSearchAlias('gt', 'Translate', 'http://translate.google.com/?source=osdd#auto|auto|');
addSearchAlias('aw', 'Arch Wiki', 'https://wiki.archlinux.org/index.php?search=');
addSearchAlias('gh', 'Github', 'https://github.com/search?utf8=✓&q=');
addSearchAlias('s', 'Scholar', 'https://scholar.google.com/scholar?hl=en&as_sdt=0,44&q=');

// omnibar
cmap('<Ctrl-j>', '<Ctrl-n>');
cmap('<Ctrl-k>', '<Ctrl-p>');

// click Save button to make above settings to take effect.
// set theme
settings.theme = `
.sk_theme {
    --main-bg-color: #2f3744;
    --main-bg-alt-color: #242e3c;
    --main-fg-color: #ffffff;
    --main-fg-highlight-color: #65ea5b;
    --fg-url: #7ac1ff;
    background-color: var(--main-bg-alt-color);
    color: var(--main-fg-color);
}
.sk_theme .focused {
    color: var(--main-fg-highlight-color) !important;
    background-color: hsla(229, 21%, 15%, 1) !important;
}
.sk_theme tbody {
    color: #2f3744;
}
.sk_theme input {
    color: var(--main-fg-highlight-color);
}
.sk_theme .url {
    color: var(--fg-url) !important;
}
.sk_theme .annotation {
    color: #38f;
}
.sk_theme #sk_omnibarSearchResult>ul>li:nth-child(even) {
    color: white;
    background-color: var(--main-bg-alt-color);
}
.sk_theme #sk_omnibarSearchResult>ul>li:nth-child(odd) {
    color: white;
    background-color: var(--main-bg-color);
}
.sk_theme #sk_omnibarSearchResult > ul {
}
/* focused item */
.sk_theme #sk_omnibarSearchResult > ul > li:hover, .sk_theme #sk_omnibarSearchResult > ul > .focused {
    cursor: pointer;
    font-size: 20px;
    background-color: var(--main-bg-alt-color);
}
.sk_theme #sk_omnibarSearchResult > ul > li {
    margin: 5px 10px;
    background-color: #2f3744;
    font-size: 16px;
    border-radius: 5px;
}`;

