React = require 'react'
ReactDOM = require 'react-dom'
{LoginForm} = require 'react-zamba/lib/login'

ReactDOM.render <LoginForm title="Submit a new referral" has_signup=false />, document.getElementById('app')

