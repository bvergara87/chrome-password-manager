init = ->
    chrome.extension.onMessage.addListener((req, sender, resp) ->
        if req.method == "put"
            localStorage[req.subdomain] = req.form_fields
        else if req.method == "get"
            if req.subdomain of localStorage
                resp({
                    form_fields: localStorage[req.subdomain]
                })
            else
                resp({
                    form_fields: null
                })
    )

main = ->
    init()

main()