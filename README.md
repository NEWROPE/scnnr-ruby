# Scnnr Ruby
Official #CBK scnnr client library for Ruby.

## Installation
### Bundler
```
gem 'scnnr', '~> 0.1'
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
Request image recognition by an image URL.

```
url = 'https://example.com/dummy.jpg'
recognition = client.recognize_url(url)

# you can override config.timeout.
recognition = client.recognize_url(url, { timeout: 10 })
```

Request image recognition by a binary image.

```
img = File.open('dummy_image_file', 'rb')
recognition = client.recognize_image(img)
```
`recognition` instance represents the image recognition result from API.
If the recognition succeeds, returned `recognition` whose state is `finished`.

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
```

If the timeout value is zero, returned `recognition` whose state is `queued`.

Then you can request again using `client#fetch`.

```
recognition.queued?
=> true

recognition.to_h
=> {"id"=>"20170829/ed4c674c-7970-4e9c-9b26-1b6076b36b49", "state"=>"queued"}

recognition = client.fetch(recognition.id)
recognition.finished?
=> true
```

### Error handling

If the recognition processing does not end within the timeout time or the recognition failed,
returned an error with `recognition` whose state is `queued`.

```
begin
  url = 'https://example.com/dummy.jpg'
  recognition = client.recognize_url(url)
rescue Scnnr::Errors::RecognitionFailed, Scnnr::Errors::TimeoutError => e
  # You can request again just like when the timeout value is zero.
  recognition = client.fetch(e.recognition.id)
  recognition.finished?
  => true
rescue Scnnr::Errors::RequestFailed => e
  # Network communication with scnnr API failed.
rescue => e
  # An error not related to the scnnr API occurred.
end
```
