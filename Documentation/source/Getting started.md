Getting started
=============================

The Gini Pay Api Library provides ways to interact with the Gini API and therefore, adds the possiblity to scan documents and retrieve the extractions from them.

## Initializing the library

To initialize the library, you just need to provide the API credentials:

```swift
    let giniPayApiLib = GiniPayApiLib
        .Builder(client: Client(id: "your-id",
                                secret: "your-secret",
                                domain: "your-domain"))
        .build()
```

Optionally if you want to use _Certificate pinning_, provide metadata for the upload process or use the [Accounting API](https://accounting-api.gini.net/documentation/), you can pass both your public key pinning configuration (see [TrustKit repo](https://github.com/datatheorem/TrustKit) for more information), the metadata information and the _API type_ (the [Gini API](http://developer.gini.net/gini-api/html/index.html) is used by default) as follows:

```swift
    let giniPayApiLib = GiniPayApiLib
        .Builder(client: Client(id: "your-id",
                                secret: "your-secret",
                                domain: "your-domain"),
                 api: .accounting,
                 pinningConfig: yourPublicPinningConfig)
        .build()
```
> ⚠️  **Important**
> - The document metadata for the upload process is intended to be used for reporting.

## Using the library

Now that the `GiniPayApiLib` has been initialized, you can start using it. To do so, just get the _Document service_ from it. 

On one hand, if you choose to continue with the `default` _Document service_, you should use the `DefaultDocumentService`:

```swift
let documentService: DefaultDocumentService = giniPayApiLib.documentService()
```

On the other hand, if you prefer to use the `accounting` _Document service_, just use the `AccountingDocumentService` as follows:

```swift
let documentService: AccountingDocumentService = giniPayApiLib.documentService()
```

You are all set 🚀! You can start using the Gini API through the `documentService`.

### Upload a document

As the key aspect of the Gini API is to provide information extraction for analyzing documents, the API is mainly built around the concept of documents. A document can be any written representation of information such as invoices, reminders, contracts and so on.

The Gini Pay API lib supports creating documents from images, PDFs or UTF-8 encoded text. Images are usually a picture of a paper document which was taken with the device’s camera.

The following example shows how to create a new document from a byte array containing a JPEG image.
```swift
documentService.createDocument(fileName: "myFirstDocument.jpg",
                            docType: docType,
                            type: .partial(document.data),
                            metadata: metadata) { result in
    switch result {
    case let .success(createdDocument):
        print("📄 Created document with id: \(createdDocument.id) " +
            "for vision document \(document.id)")
        completion(.success(createdDocument))
    case let .failure(error):
        print("❌ Document creation failed: \(error)")
        completion(.failure(error))
    }
}
```

Each page of a document needs to uploaded as a partial document. In addition documents consisting of one page also should be uploaded as a partial document.

> ⚠️  **Note**
> - PDFs and UTF-8 encoded text should also be uploaded as partial documents. Even though PDFs might contain multiple pages and text is “pageless”, creating partial documents for these keeps your interaction with Gini consistent for all the supported document types.

Extractions are not available for partial documents. Creating a partial document is analogous to an upload. For retrieving extractions see Getting extractions section.

> ⚠️  **Note**
> - The `filename` (myFirstDocument.jpg in the example) is not required, it could be nil, but setting a filename is a good practice for human readable document identification.

#### Setting the document type hint

To easily set the document type hint we introduced the `DocType` enum. It is safer and easier to use than a String. For more details about the document type hints see the Document Type Hints in the [Gini Pay API documentation](https://pay-api.gini.net/documentation/#document-types)

### Getting extractions

After you have successfully created the partial documents, you most likely want to get the extractions for the document. Composite documents consist of previously created partial documents. You can consider creating partial documents analogous to uploading pages of a document and creating a composite document analogous to processing those pages as a single document.

Before retrieving extractions you need to create a composite document from your partial documents

Gini needs to process the composite document first before you can fetch the extractions. Effectively this means that you won’t get any extractions before the composite document is fully processed. The processing time may vary, usually it is in the range of a couple of seconds, but blurred or slightly rotated images are known to drasticly increase the processing time.

The `DocumentService` provides `extractions()` method which can be used to fetch the extractions after the processing of the document is completed. The following example shows how to achieve this in detail.

```swift
documentService
    .createDocument(fileName: "composite-myFirstDocument.jpg",
                    docType: nil,
                    type: .composite(CompositeDocumentInfo(partialDocuments: documents)),
                    metadata: metadata) { [weak self] result in
    guard let self = self else { return }
    switch result {
    case let .success(createdDocument):
        print("🔎 Starting analysis for composite document with id \(createdDocument.id)")
        self.documentService.extractions(for: createdDocument,
                           cancellationToken: CancellationToken()) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(extractionResult):
                    completion(.success(extractionResult.extractions))
                    print("The specific extractions: \(extractionResult.extractions)")
                    print("The line item compound extractions : \(extractionResult.lineItems)")
                case let .failure(error):
                    completion(.failure(.apiError(error)))
                }
            }
        }
    case let .failure(error):
        print("❌ Composite document creation failed: \(error)")
        completion(.failure(error))
    }
}
```

### Sending feedback

Depending on your use case your app probably presents the extractions to the user and gives them the opportunity to correct them. By sending us feedback for the extractions we are able to continuously improve the extraction quality.

Your app should send feedback only for the extractions the user has seen and accepted. Feedback should be sent for corrected extractions and for correct extractions. The code example below shows how to correct extractions and send feedback.

```swift
guard let document = document else { return }

// specific extractions,that we've received in the section above
var updatedExtractions: [Extraction] = extractionResult.extractions

// amountToPay was wrong, we'll correct it
updatedExtractions.first {
    $0.name == "amountToPay"
}?.value = "31:00:EUR"

documentService.submitFeedback(for: document, with: updatedExtractions) { result in
    switch result {
    case .success:
        print("🚀 Feedback sent with \(updatedExtractions.count) extractions")
    case .failure(let error):
        print("❌ Error sending feedback for document with id: \(document.id) error: \(error)")
    }
}
```

### Handling errors

All errors that occur during request execution are handed over transparently. You can react on those errors in the `failure` case of the completion result. We recommend checking the network status when a request failed and retrying it.