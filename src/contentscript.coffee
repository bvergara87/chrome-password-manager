sendFormFields = (form_fields, subdomain) ->
    chrome.runtime.sendMessage({
        method: "put"
        form_fields: JSON.stringify(form_fields)
        subdomain: subdomain
    })

fetchFormFields = (subdomain, defer_cb) ->
    chrome.runtime.sendMessage {
        method: "get"
        subdomain: subdomain
    }, (resp) ->
        defer_cb(JSON.parse(resp.form_fields))

###
Returns an associative array that maps the name of each form field
###
sieveFormFields = (form_obj) ->
    arr = {}
    for field in $(form_obj).find("input")
        if $(field).attr("name")? and $(field).attr("name") != ""
            arr[$(field).attr("name")] = $(field).val()
    return arr

initBindings = ->
    $("form").on "submit", (e) ->
        form_fields = sieveFormFields(this)
        subdomain = window.location.host
        sendFormFields(form_fields, subdomain)

    $(document).ready ->
        subdomain = window.location.host
        console.log "checking for page info"
        await fetchFormFields subdomain, defer(plausible_form_fields)
        if plausible_form_fields?
            for k,v of plausible_form_fields
                $("input[name=#{k}]").val(v)

main = ->
    initBindings()

main()