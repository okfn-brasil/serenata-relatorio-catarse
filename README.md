# Rosie nas Eleições 2018

Repositório com as suspeitas da [Rosie](https://twitter.com/RosieDaSerenata)
relacionadas a candidatos nas eleições 2018.

## Requisitos

* Node.js
* Python (apenas para rodar um servidor local)

## Desenvolvimento

```sh
$ npm install
$ npm run dev
$ cd dist && python -m http.server && cd ..
```

> Se você estiver com Python 2, use `python -m SimpleHTTPServer 8000` ao invés de
`python -m http.server`.

Aí é só abrir [`localhost:8000`](http://localhost:8000) no seu navegador.

## Produção

```sh
$ npm run build
```

E então é só publicar o conteúdo de `dist/` no seu servidor.
