@ignore
Feature:

  Scenario: Adding product into form
    * def parameters = {body: '#(body)', product: '#(currentProduct)'}
    * print parameters.product
    * set parameters.body.formBody.application.selectedProduct.virtualProductId = parameters.product.virtualProductId
    * set parameters.body.formBody.application.selectedProduct.virtualProductName = parameters.product.virtualProductName
    * set parameters.body.formBody.application.selectedProduct.title = parameters.product.title
    * set parameters.body.formBody.application.selectedProduct.description = parameters.product.description
    * set parameters.body.formBody.application.selectedProduct.learnMore = parameters.product.learnMore
    * set parameters.body.formBody.application.selectedProduct.tcLink = parameters.product.tcLink
    * set parameters.body.formBody.application.selectedProduct.tcVersion = parameters.product.tcVersion
    * set parameters.body.formBody.application.selectedProduct.products = parameters.product.products
    * def body = parameters.body
