const express = require("express") // npm install express
const fetch = require("node-fetch") // npm install node-fetch@2.6.6
const FS = require("fs")
const app = express()
const Jimp = require("jimp")

function randomstr(length) {
    var result           = '';
    var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    var charactersLength = characters.length;
    for ( var i = 0; i < length; i++ ) {
      result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
   return result;
}

app.use("/api/png2json/v1/", async(req, res) => {
    const data = await fetch(req.query.url).then(response => {return response.buffer()})
    const randomfilename = randomstr(32) + "." + req.query.url.split(".")[req.query.url.split(".").length - 1]
    FS.writeFileSync("./temp/" + randomfilename, data)
    if(req.query.compress){
        Jimp.read("./temp/" + randomfilename)
        .then(image => {
            var width = image.bitmap.width;
            var height = image.bitmap.height;
            var pixels = [];
            var cuboids = 0
            var IsVisited = []
            var colorThresh = new Number(req.query.compress)
            var final = []
            for(var x = 1; x <= width;x++){
                pixels[x] = {}
                IsVisited[x] = {}
                for(var y = 1; y <= height;y++){
                    var pixel = Jimp.intToRGBA(image.getPixelColor(x, y));
                    IsVisited[x][y] = false
                    pixels[x][y] = {
                        R: pixel.r / 255,
                        G: pixel.g / 255,
                        B: pixel.b / 255
                    }
                }
            }
            let array = pixels
            for(var x = 1; x <= width;x++){
                for(var z = 1;z <= height;z++){
                    if(IsVisited[x][z] == false){
                        let startX = x
                        let startZ = z
                        let endX = x
                        let endZ = z
                        IsVisited[x][z] = true   

                        while(endX < width){
                            let newEndX = endX + 1
                            let colorDist = Math.sqrt(
                                Math.pow(array[newEndX][z].R-array[startX][z].R, 2) + 
                                Math.pow(array[newEndX][z].G-array[startX][z].G, 2) + 
                                Math.pow(array[newEndX][z].B-array[startX][z].B, 2)
                            )
                            let isUseable = (IsVisited[newEndX][z] == false && array[newEndX] && array[newEndX][z] && colorDist < colorThresh)
                            if(!isUseable){
                                break
                            }else{
                                IsVisited[newEndX][z] = true
                                endX = newEndX
                            }
                        }
                        while(endZ < height){
                            let newEndZ = endZ + 1
                            let isRowUseable = true
                            for(var dx=startX;dx <= endX;dx++){
                                let colorDist = Math.sqrt(
                                    Math.pow(array[dx][endZ].R-array[dx][startZ].R, 2) + 
                                    Math.pow(array[dx][endZ].G-array[dx][startZ].G, 2) + 
                                    Math.pow(array[dx][endZ].B-array[dx][startZ].B, 2)
                                )
                                let isUseable = (IsVisited[dx][newEndZ] == false && array[dx] && array[dx][newEndZ] && colorDist < colorThresh)
                                if(!isUseable){
                                    isRowUseable = false
                                    break
                                }
                            }
                            if(!isRowUseable){
                                break
                            }else{
                                for(var dx=startX;dx <= endX;dx++){
                                    IsVisited[dx][newEndZ] = true
                                }

                                endZ = newEndZ
                            }
                        }
                        final.push({
                            startX: startX,
                            startZ: startZ,
                            endX: endX,
                            endZ: endZ,
                            color: array[startX][z]
                        })
                    }
                }
            }
            res.send({ data: final, cuboids: final.length, width: width, height: height })
            FS.unlinkSync("./temp/" + randomfilename)
        })
        .catch(err => { throw err; });
    }else{
        Jimp.read("./temp/" + randomfilename)
        .then(image => {
            var width = image.bitmap.width;
            var height = image.bitmap.height;
            var pixels = [];
            for (var x = 0; x < width; x++) {
                pixels[x] = []
                for (var y = 0; y < height; y++) {
                    pixels[x][y] = []
                    var pixel = Jimp.intToRGBA(image.getPixelColor(x, y));
                    pixels[x][y].push(pixel.r);
                    pixels[x][y].push(pixel.g);
                    pixels[x][y].push(pixel.b);
                }
            }
            res.send({ data: pixels })
            FS.unlinkSync("./temp/" + randomfilename)
        })
        .catch(err => { throw err; });
    }
})

app.listen(1336)