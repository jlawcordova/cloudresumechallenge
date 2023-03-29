/// <reference types="cypress" />

describe("Resume", () => {
  beforeEach(() => {
    cy.visit("/");
  });

  it("should contain the name of the resume owner", () => {
    cy.get("h1").should("contain", "Junel Lawrence Cordova");
  });

  it("should return the view count when visited", () => {
    cy.get(".view-count").then((content) => {
      var viewCount = parseInt(content[0].innerText.split(" ")[0]);
      cy.wrap(viewCount).should("be.a", "number");
    });
  });
});
