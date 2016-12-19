@media (min-width: 48em) {
    .site-main {
        -webkit-box-flex: 1;
        -webkit-flex: 1 1 auto;
        -ms-flex: 1 1 auto;
        flex: 1 1 auto;
        margin-left: 20rem;
        min-height: calc(100vh - 5.375rem);
		border-left: 1px solid #D8DDE6;
		padding-left: 40px;
    }
}
@media (min-width: 64em) {
    .site-main {
        min-height: calc(100vh - 3.125rem)
    }
}
.site-navigation {
    padding-top: 1.5rem;
    padding-bottom: 1.5rem
}
.site-navigation a {
    display: block;
    padding: 0.75rem 2rem;
    line-height: 1.28571428571429;
    color: #16325c
}
.site-navigation a:hover {
    background-color: rgba(244, 246, 249, 0.5)
}
.site-navigation .slds-is-open {
    padding-bottom: 0.5rem
}
.site-navigation .is-closed ul {
    display: none
}
.site-navigation .slds-is-selected {
    background-color: #f4f6f9
}
.site-navigation .slds-is-selected a:hover {
    background-color: #eceff5
}
.site-navigation .is-active>a {
    color: #0070d2
}
.site-navigation .slds-is-nested {
    margin-left: 0
}
.site-navigation .slds-is-nested a {
    padding-top: 0.5rem;
    padding-bottom: 0.5rem;
    padding-left: 3.5rem
}
.site-navigation .slds-is-nested .slds-is-nested a {
    padding-left: 5rem
}
.site-navigation>ul .icon__svg {
    width: 0.5rem;
    height: 0.5rem;
    display: inline-block;
    opacity: .5
}
.site-navigation>ul .slds-is-selected>a .icon__svg {
    opacity: 1
}
@media (min-width: 48em) {
    .site-navigation {
        float: left;
        top: 6rem;
        bottom: 0;
        padding-top: 0;
        width: 20rem;
        overflow: hidden;
        overflow-y: auto;
		padding: 32px 0px 0px 0px;
    }
    .site-navigation::-webkit-scrollbar {
        width: 10px;
        height: 10px
    }
    .site-navigation::-webkit-scrollbar:window-inactive {
        opacity: 0
    }
    .site-navigation::-webkit-scrollbar-thumb {
        background: #e0e5ee;
        border-radius: 0.5rem;
        box-shadow: #a8b7c7 0 0 0 1px inset
    }
    .site-navigation::-webkit-scrollbar-track {
        background: #a8b7c7
    }
}