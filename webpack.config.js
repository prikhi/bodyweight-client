var path = require("path");

module.exports = {
  entry: {
    app: [
      './src/index.js',
    ],
  },

  output: {
    path: path.resolve(__dirname + '/dist'),
    filename: '[name].js'
  },

  module: {
    loaders: [
      {
        test: /\.html$/,
        exclude: /node_modules/,
        loader: 'file?name=[name].[ext]',
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/,],
        loader: 'elm-hot!elm-webpack?warn=true&verbose=true',
      },
      {
        test: /\.sass$/,
        exclude: /node_modules/,
        loaders: ['style', 'css', 'sass'],
      },
      {
        test: /\.css$/,
        exclude: /node_modules/,
        loaders: ['style', 'css']
      },
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "url-loader?limit=10000&minetype=application/font-woff"
      },
      { test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "file-loader" 
      },
    ],

    noParse: /\.elm$/,
  },

  devServer: {
    inline: true,
    host: '0.0.0.0',
    stats: {
      colors: true,
      chunks: false,
    },
    proxy: {
      '/api/*': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        pathRewrite: { "^/api/": "" },
      }
    }
  },

};
