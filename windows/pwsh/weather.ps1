# Use 'wttr.in' services
# U can check the repos at 'https://github.com/chubin/wttr.in'

function weather {
    param (
        [string]$location
    )

    $defaultCity = "{urCity}"

    if ([string]::IsNullOrEmpty($location)) {
        curl "http://wttr.in/$defaultCity"
    } else {
        curl "http://wttr.in/$location"
    }
}
