const express = require('express');
const app = express();
const router = express.Router();

const path = __dirname + '/views/';
const port = 5000;

router.use(function (req,res,next) {
  next();
});

router.get('/', function(req,res){
  res.sendFile(path + 'index.html');
});

app.use('/assets/', express.static('/apps/gzweb/http/client/assets/'));
app.use(express.static(path));
app.use('/', router);

app.listen(port, function () {
})

