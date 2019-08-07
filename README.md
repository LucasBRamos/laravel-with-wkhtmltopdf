# Laravel With Wkhtmltopdf

Imagem Docker para rodar projetos em Laravel e conseguir gerar PDF a partir do container.

Para criação da imagem, foi utilizado a configuração do Dockerfile do php ambientum, sendo adicionado a configuração para instalação das dependências do Wkhtmltopdf


## Rodando o container

A imagem foi criada no contexto de rodar projetos em Laravel, assim sendo, a pasta pública configurada é a pasta ```public```.

Para rodar, cole em seu dockerfile o código abaixo:

```
version: '3'

services:
	app:
	    image: lucasramos/laravel-sqlsrv:1.0.0
	    container_name: container_name
	    network_mode: "bridge"
	    volumes:
	      - .:/var/www/
	    ports:
	      - "80:80"
```
