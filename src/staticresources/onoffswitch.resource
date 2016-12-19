.onoffswitch {
    position: relative; width: 90px !important;
    -webkit-user-select:none; -moz-user-select:none; -ms-user-select: none !important;
}
.onoffswitch-checkbox {
    display: none !important;
}
.onoffswitch-label {
    display: block; overflow: hidden; cursor: pointer !important;
    border: 2px solid #999999; border-radius: 4px !important;
}
.onoffswitch-inner {
    display: block; width: 200%; margin-left: -100% !important;
    transition: margin 0.3s ease-in 0s !important;
}
.onoffswitch-inner:before, .onoffswitch-inner:after {
    display: block; float: left; width: 50%; height: 30px; padding: 0; line-height: 30px !important;
    font-size: 14px; color: white; font-family: Trebuchet, Arial, sans-serif; font-weight: bold !important;
    box-sizing: border-box !important;
}
.onoffswitch-inner:before {
    content: "YES" !important;
    padding-left: 10px !important;
    background-color: #54698D; color: #FFFFFF !important;
}
.onoffswitch-inner:after {
    content: "NO" !important;
    padding-right: 10px !important;
    background-color: #EEEEEE; color: #999999 !important;
    text-align: right !important;
}
.onoffswitch-switch {
    display: block; width: 21px; margin: 4.5px !important;
    background: #FFFFFF !important;
    position: absolute; top: 0; bottom: 0 !important;
    right: 56px !important;
    border: 2px solid #999999; border-radius: 4px !important;
    transition: all 0.3s ease-in 0s !important; 
}
.onoffswitch-checkbox:checked + .onoffswitch-label .onoffswitch-inner {
    margin-left: 0 !important;
}
.onoffswitch-checkbox:checked + .onoffswitch-label .onoffswitch-switch {
    right: 0px !important; 
}