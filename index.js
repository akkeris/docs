const express 	 = require('express')
let app 	 = express()

app.use("/", express.static(__dirname + '/_book'))
app.listen(process.env.PORT || 9000, () => {
	console.log(`Listening on ${process.env.PORT || 9000}...`)
})
