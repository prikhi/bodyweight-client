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
        loader: 'elm-hot!elm-webpack?warn=true',
      },
    ],

    noParse: /\.elm$/,
  },

  devServer: {
    inline: true,
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
