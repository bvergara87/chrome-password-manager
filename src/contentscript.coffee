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
        if $(field).css("display","none") or $(field).css("visibility","hidden")
            continue

        if $(field).attr("type") == "hidden"
            continue

        if $(field).attr("name")? and $(field).attr("name") != ""
            arr[$(field).attr("name")] = $(field).val()

    return arr

getUrl = ->
    location.host + location.pathname

isPlausibleLoginPage = ->
    all_forms = $("form")
    is_login_page = false
    for f in all_forms
        if $(f).find("input[type=password]").length == 1
            is_login_page = true
    is_login_page

initBindings = ->
    $("form").on "submit", (e) ->
        if isPlausibleLoginPage()
            form_fields = sieveFormFields(this)
            url = getUrl()
            sendFormFields(form_fields, url)

    $(document).ready ->
        if isPlausibleLoginPage()
            url = getUrl()
            await fetchFormFields url, defer(plausible_form_fields)
            console.log plausible_form_fields
            if plausible_form_fields?
                for k,v of plausible_form_fields
                    $("input[name=#{k}]").val(v)

main = ->
    initBindings()

main()