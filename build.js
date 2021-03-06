const { execSync } = require('child_process');
var fs = require('fs');


console.log('Building Client')
console.log(run_cmd('yarn webbuild'))
// copyFile('./dist/index.html', './build/index.html')

console.log('Building Server')
console.log(run_cmd('pyinstaller -F ./build.spec', path = "./server/win64"))
copyFile('./server/win64/dist/vTablet.exe', './build/vTablet.exe')


console.log('Finished!')

function run_cmd(cmd, path = './') {
  return execSync(cmd,{stdio:[0,1,2], cwd: path})
}

function copyFile(src, dist) {
  fs.writeFileSync(dist, fs.readFileSync(src));
}