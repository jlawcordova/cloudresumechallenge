# The Resume

This project performs end-to-end tests to [J. Law. Cordova's](https://github.com/jlawcordova) resume using [Cypress](https://www.cypress.io/). This is part of [The Cloud Resume Challenge (AWS Edition)](https://cloudresumechallenge.dev/docs/the-challenge/aws/) and covers 11 (Tests).

## The Cloud Resume Challenge

From the [challenge website](https://cloudresumechallenge.dev/docs/faq/#what-is-the-cloud-resume-challenge),

> The Cloud Resume Challenge is a hands-on project designed to help you bridge the gap from cloud certification to cloud job. It incorporates many of the skills that real cloud and DevOps engineers use in their daily work.

## Opening Cypress

In the project root, run:

`npm run cypress:open`

After a moment, the Cypress Launchpad will open.

`npm test`

## Running from the CLI

By default the production environment at [https://resume.jlawcordova.com](https://resume.jlawcordova.com) is tested. If needed, this can be changed by modifying `e2e.baseUrl` and `env.apiUrl` in [`cypress.config.ts`](./cypress.config.ts).

In the project root, run:

`npm run cypress:run`

This runs Cypress tests to completion.
