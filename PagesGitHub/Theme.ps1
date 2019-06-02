###Sets the themes throughout the form, this did work flawless in 2.4.0
New-UDTheme -Name "Basic" -Definition @{
    '.btn'                                                                                                                          = @{
        'color'            = "#ffffff"
        'background-color' = "#f2c14e"
    }
    '.btn:hover'                                                                                                                    = @{
        'color'            = "#ffffff"
        'background-color' = "#033584"
    }
    '.select-dropdown li span'                                                                                                      = @{
        'color' = "#339933"
    }
    '[type="radio"]:checked+label:after, [type="radio"].with-gap:checked+label:after'                                               = @{
        'background-color' = 'green'
        'border-radius'    = '50%'
    }
    '[type="radio"]:checked+label:after, [type="radio"].with-gap:checked+label:before, [type="radio"].with-gap:checked+label:after' = @{
        'border' = '2px solid green'
    }
    '.tabs .tab'                                                                                                                    = @{
        'color' = "#000"
    }

    '.tabs .tab a:hover'                                                                                                            = @{
        'background-color' = "#033584"
        'color'            = "#ffffff"
    }

    '.tabs .tab a.active'                                                                                                           = @{
        'background-color' = "#4392f1"
        'color'            = "#ffffff"
    }
    '.tabs .tab a:focus.active'                                                                                                     = @{
   'background-color' = "#4392f1"
        'color'            = "#ffffff"
    }
    '.tabs .indicator'                                                                                                              = @{
        'background-color' = "#339933"
    }
    '.tabs .tab a'                                                                                                                  = @{
        'color' = "#000000"
    }
    UDInput                                                                                                                         = @{
        BackgroundColor = "rgb(255,255,255)"
        FontColor       = "rgb(51, 153, 51)"
    }
    UDGrid                                                                                                                          = @{
        BackgroundColor = "#ffffff"
        FontColor       = "#000000"
    }
    UDCounter                                                                                                                       = @{
        BackgroundColor = "#4392f1"
        FontColor       = "#ffffff"
    }
    UDCard                                                                                                                          = @{
        BackgroundColor = "#4392f1"
        FontColor       = "#ffffff"
    }
    '.ud-percentage'                                                                                                                = @{
        height = '100%'
    }
    '.centertext'                                                                                                                   = @{
        'text-align' = 'center'
    }
    '.percent-right'                                                                                                                = @{
        height        = '100%'
        Width         = '250px'
        'text-align'  = 'center'
        'white-space' = 'nowrap'
        'margin-left' = 'auto'
    }
}