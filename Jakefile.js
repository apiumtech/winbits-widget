var cpTemplates, dataBindig, fs, handlebars, sys, _;

sys = require("sys");
fs = require("fs");
handlebars = require("handlebars");
_ = require("underscore");

desc("This is the default task and doesnt do nada.");
task("default", function() {
  return console.log("jake -T  to see a list of avalible tasks");
});



desc("task to build just must change enviroment before build");
task("build", function() {
  var cmds;
  //cmds = ["jake deploy-field",
  cmds = [
  "rm -rf public",
  "brunch build --optimize"
  ];
  //"node /opt/apps/qa/stage/harvesting/harvesting.js /var/www/lat/ http://sowingfield.clickonero.com.mx/#store/ https://www.clickonero.com.mx/store;"];
  console.log("going to execute this");
  console.log(cmds);
  return jake.exec(cmds, (function() {
    console.log("app ready");
    return complete();
  }), {
    stdout: true
  });
});


desc("switch config posible args: dev, qa, staging, prod ");
task("switch-config", function() {
  var env, envJson, execFile, fileContents, file_list, schema;
  jake.rmRf(".tmp/");
  env = arguments[0];
  console.log("switching config ... to " + env);
  fileContents = fs.readFileSync("deploy/enviroments.js", "utf8");
  schema = JSON.parse(fileContents);
  envJson = _.find(schema.enviroments, function(envc) {
    return envc.name === env;
  });
  console.log(envJson);
  file_list = "";
  execFile = require("child_process").execFile;
  return execFile("find", ["deploy/resources/", "-name", "*.hbs"], function(err, stdout, stderr) {
    file_list = "" + stdout.split("\n");
    return _.each(file_list.split(","), function(file) {
      if (file !== "") {
        console.log("processing ---> " + file);
        dataBindig(file, envJson.config);
        return cpTemplates();
      }
    });
  });
});

dataBindig = function(tmplFile, json) {
  var dir, encoding, fileTest, newDir, newName, tmpl;
  fileTest = fs.readFileSync(tmplFile, "utf8");
  tmpl = handlebars.compile(fileTest);
  newDir = ".tmp/";
  dir = tmplFile.split("/");
  newName = dir[dir.length - 1];
  dir = tmplFile.replace(newName, "");
  newDir = newDir + dir;
  newName = newName.replace(".hbs", "");
  jake.mkdirP(newDir);
  return fs.writeFileSync(newDir + newName, tmpl(json), encoding = "utf8", function(err) {
    if (err) {
      return console.log(err);
    } else {
      return console.log("the file" + tmplFile + " was processed to -> " + newDir + newName);
    }
  });
};

cpTemplates = function() {
  var cmds;
  cmds = ["cp -rf .tmp/deploy/resources/app/* app/"];
  return jake.exec(cmds, (function() {
    console.log("resources populated and moved to -> /app");
    return complete();
  }), {
    stdout: true
  });
};
