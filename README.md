# Official #CBK scnnr client library for Ruby.
[![CircleCI](https://circleci.com/gh/NEWROPE/scnnr-ruby.svg?style=svg)](https://circleci.com/gh/NEWROPE/scnnr-ruby)

- [#CBK scnnr](https://scnnr.cubki.jp/)
- [API Documentation](https://api.scnnr.cubki.jp/v1/docs)

## Supported Ruby versions
- Ruby 2.4+

## Installation

### Bundler

```
gem 'scnnr'
```

### Manual

```
gem install scnnr
```

## Configuration

You can pass configuration options as a block to `Scnnr::Client.new`.

```
client = Scnnr::Client.new do |config|
  config.api_key = 'YOUR API KEY'
  config.api_version = 'v1'
  config.timeout = 0 # sec
  config.logger = Logger.new(STDOUT) # You can specify an alternative logger.
  config.logger.level = :info # You can change the default log level.
end
```

## Examples

### Basic usage

#### Recognize images

Request image recognition by an image URL.

Refer: [`POST /v1/remote/recognitions`](https://api.scnnr.cubki.jp/v1/docs#tag/remoterecognitions%2Fpaths%2F~1remote~1recognitions%2Fpost)

```
url = 'https://example.com/dummy.jpg'
recognition = client.recognize_url(url)

# You can override config.timeout.
recognition = client.recognize_url(url, timeout: 10)
```

Request image recognition by a binary image.

Refer: [`POST /v1/recognitions`](https://api.scnnr.cubki.jp/v1/docs#tag/recognitions%2Fpaths%2F~1recognitions%2Fpost)

```
img = File.open('dummy_image_file', 'rb')
recognition = client.recognize_image(img)

# You can use public parameter as well.
recognition = client.recognize_image(img, timeout: 10, public: true)
```

`Recognition` class represents the image recognition result from API.
If the recognition processing is completed, you will get `Recognition` instance whose state is `finished`.

```
recognition.finished?
=> true

recognition.to_h
=> {"id"=>"20170829/ed4c674c-7970-4e9c-9b26-1b6076b36b49",
 "objects"=>
  [{"bounding_box"=>{"bottom"=>0.2696995, "left"=>0.3842466, "right"=>0.57190025, "top"=>0.14457992},
    "category"=>"hat",
    "labels"=>
     [{"name"=>"ハット", "score"=>0.9985399},
      {"name"=>"中折れ", "score"=>0.99334323},
      {"name"=>"ストローハット", "score"=>0.95629793},
      {"name"=>"ベージュ", "score"=>0.9062561},
      {"name"=>"つば広ハット", "score"=>0.7737022},
      {"name"=>"ホワイト", "score"=>0.5695046}]},
   {"bounding_box"=>{"bottom"=>0.95560884, "left"=>0.41641566, "right"=>0.5212327, "top"=>0.8452401},
    "category"=>"shoe",
    "labels"=>
     [{"name"=>"サンダル", "score"=>0.93934095},
      {"name"=>"ホワイト", "score"=>0.74320596},
      {"name"=>"パンプス", "score"=>0.70763165},
      {"name"=>"サボ", "score"=>0.69153166},
      {"name"=>"ストラップ", "score"=>0.66519636},
      {"name"=>"ウェッジソール", "score"=>0.6325865},
      {"name"=>"オープントゥ", "score"=>0.61965847},
      {"name"=>"アンクルストラップ", "score"=>0.576824},
      {"name"=>"厚底", "score"=>0.53842664}]},
   {"bounding_box"=>{"bottom"=>0.7018228, "left"=>0.35182703, "right"=>0.6113004, "top"=>0.25296396},
    "category"=>"dress",
    "labels"=>[{"name"=>"グリーン", "score"=>0.9765959}, {"name"=>"ワンピース", "score"=>0.94697183}, {"name"=>"カーキ", "score"=>0.8136864}, {"name"=>"無地", "score"=>0.54719794}, {"name"=>"フレア", "score"=>0.51572186}]}],
 "state"=>"finished"}

# If you recognize an image with `public` parameter, the `recognition` has `image`.
recognition.to_h
=> {"id"=>"20170829/ed4c674c-7970-4e9c-9b26-1b6076b36b49",
 "image"=>
  {"url"=>"some-image-url",
   "size"=>{"height"=>400, "width"=>400}},
 "objects"=>
  [{"bounding_box"=>{"bottom"=>0.2696995, "left"=>0.3842466, "right"=>0.57190025, "top"=>0.14457992},
    "category"=>"hat",
    "labels"=>
     [{"name"=>"ハット", "score"=>0.9985399},
      {"name"=>"中折れ", "score"=>0.99334323},
      {"name"=>"ストローハット", "score"=>0.95629793},
      {"name"=>"ベージュ", "score"=>0.9062561},
      {"name"=>"つば広ハット", "score"=>0.7737022},
      {"name"=>"ホワイト", "score"=>0.5695046}]},
   {"bounding_box"=>{"bottom"=>0.95560884, "left"=>0.41641566, "right"=>0.5212327, "top"=>0.8452401},
    "category"=>"shoe",
    "labels"=>
     [{"name"=>"サンダル", "score"=>0.93934095},
      {"name"=>"ホワイト", "score"=>0.74320596},
      {"name"=>"パンプス", "score"=>0.70763165},
      {"name"=>"サボ", "score"=>0.69153166},
      {"name"=>"ストラップ", "score"=>0.66519636},
      {"name"=>"ウェッジソール", "score"=>0.6325865},
      {"name"=>"オープントゥ", "score"=>0.61965847},
      {"name"=>"アンクルストラップ", "score"=>0.576824},
      {"name"=>"厚底", "score"=>0.53842664}]},
   {"bounding_box"=>{"bottom"=>0.7018228, "left"=>0.35182703, "right"=>0.6113004, "top"=>0.25296396},
    "category"=>"dress",
    "labels"=>[{"name"=>"グリーン", "score"=>0.9765959}, {"name"=>"ワンピース", "score"=>0.94697183}, {"name"=>"カーキ", "score"=>0.8136864}, {"name"=>"無地", "score"=>0.54719794}, {"name"=>"フレア", "score"=>0.51572186}]}],
 "state"=>"finished"}
```

If the timeout value is zero or `nil`, you will get `Recognition` instance whose state is `queued`.

Then you can fetch the recognition result using `Scnnr::Client#fetch`.

Refer: [`GET /v1/recognitions/*`](https://api.scnnr.cubki.jp/v1/docs#tag/recognitions%2Fpaths%2F~1recognitions~1*%2Fget)

```
recognition.queued?
=> true

recognition.to_h
=> {"id"=>"20170829/ed4c674c-7970-4e9c-9b26-1b6076b36b49", "state"=>"queued"}

recognition = client.fetch(recognition.id)
recognition.finished?
=> true
```

#### Generate fashion coordinates

Request fashion coordinates generation.

Refer: [`POST /v1/coordinates`](https://api.scnnr.cubki.jp/v1/docs#tag/coordinates%2Fpaths%2F~1coordinates%2Fpost)

```
tastes = { casual: 0.7, girly: 0.3 }
coordinate = client.coordinate('tops', ['グレー', 'パーカー'], tastes, target: 3)

coordinate.to_h
=> {"items"=>
  [{"category"=>"tops", "labels"=>[{"name"=>"グレー", "score"=>nil}, {"name"=>"パーカー", "score"=>nil}]},
   {"category"=>"shoe",
    "labels"=>
     [{"name"=>"ネイビー", "score"=>nil},
      {"name"=>"スニーカー", "score"=>nil},
      {"name"=>"ランニング", "score"=>nil}]},
   {"category"=>"dress",
    "labels"=>
     [{"name"=>"デニム", "score"=>nil},
      {"name"=>"ブルー", "score"=>nil},
      {"name"=>"サロペット", "score"=>nil},
      {"name"=>"オーバーオール", "score"=>nil}]}]}
```

### Error handling

If the recognition processing is not completed within the timeout time or the recognition failed,
you will get an error with `Recognition` instance.

```
begin
  url = 'https://example.com/dummy.jpg'
  recognition = client.recognize_url(url, timeout: 10)
rescue Scnnr::TimeoutError => e
  # You can fetch the result just like when the timeout value is zero or nil.
  recognition = client.fetch(e.recognition.id, timeout: 10)
  recognition.finished? # => true or false
rescue Scnnr::RecognitionFailed => e
  # Failed to recognize the image you requested.
  recognition = e.recognition
  recognition.error? # => true
  STDERR.puts "[ERROR] #{e.title}: #{e.detail} #{e.type}"
rescue Scnnr::RequestFailed => e
  # Failed to reserve the recognition.
  # This kind of errors have no `#recognition` field.
  STDERR.puts "[ERROR] #{e.title}: #{e.detail} #{e.type}"
rescue Scnnr::RecognitionNotFound => e
  # Failed to find the recognition with the specified ID.
  # This kind of errors have no `#recognition` field.
  STDERR.puts "[ERROR] #{e.title}: #{e.detail} #{e.type}"
rescue => e
  # Unexpected error.
  raise
end
```
