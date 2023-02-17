const path = require("path");
const webpack = require("webpack");
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  entry: "./src/index.ts",
  mode: "development",
  
  // Documentation for Webpack: https://webpack.js.org/
  module: {
    rules: [
      
      // Documentation for TS Loader: https://github.com/TypeStrong/ts-loader
      {
        // Documentation for Javascript regular expressions: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions
        test: /\.(ts|tsx)$/,        
        loader: "ts-loader"
      },
      
      {
        test: /\.scss$/,

        // Remember, the loader chain is processed in reverse order.  This means each Sass file is passed to sass-loader.  The 
        // output of sass-loader is passed to css-loader and then the output of css-loader is passed to style-loader.  Here is
        // what the loaders do:
        // 
        // 1. The sass-loader converts Sass (scss) files into CSS files.  The sass-loader uses the node-sass package to do this.  
        //    For more information, please see https://webpack.js.org/loaders/sass-loader and https://sass-lang.com/ .
        //
        // 2. The css-loader takes a CSS file and converts it into a JavaScript module that contains CSS.  For more information,
        //    please see https://webpack.js.org/loaders/css-loader/ and https://developer.mozilla.org/en-US/docs/Web/CSS .
        //
        // 3. The style-loader takes the CSS found by the css-loader and puts it into the DOM.  It does this by creating a <style> 
        //    tag and adding the tag to an HTML document.  For more information, please see
        //    https://webpack.js.org/loaders/style-loader/ and https://developer.mozilla.org/en-US/docs/Web/HTML/Element/style .
        //
        use: ["style-loader", "css-loader", "sass-loader"]
      },

      // TODO - Remove if not needed
      {
        test: /\.(png|svg|jpeg)$/,
        type: 'asset/resource',
      },
    ]
  },
  
  // Produce high quality source maps for the debug build.  The source map allows use to see the line in the original source code.
  // (https://webpack.js.org/configuration/devtool/)
  devtool: 'eval-source-map', 

  output: {
    path: path.resolve(__dirname, "dist/"),
    publicPath: "/",
    filename: "index.js",
    
    clean: true
  },
  
  devServer: {
    static: path.join(__dirname, "dist/"),
    port: 57230,

    // Documentation for Hot Module Replacement: 
    // - https://webpack.js.org/concepts/hot-module-replacement/
    // - https://webpack.js.org/guides/hot-module-replacement/
    hot: false
  },

  plugins: [
    // Documentation for HtmlWebpackPlugin: https://github.com/jantimon/html-webpack-plugin
    new HtmlWebpackPlugin({
      template: 'src/index.html',
      meta: {
        charset: 'utf-8',
        viewport: 'width=device-width'
      }
    })
  ]
};