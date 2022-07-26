# Google Motion Photo Tools

## Introduction
While traditionally, photos have been static, some smartphone vendors nowadays offer functionality in their camera software to capture a short video clip to accompany static images in an attempt to offer more lively recollection of the associated memories. Different vendors have different names for this: Google and Samsung call it 'Motion Photo', Apple 'Live Photo'. However, there is no unified standard for the format of these video-enriched photos.

I recently embarked on the tedious process of migrating my Google Photos library to a different account. I wanted to download all my pictures and videos through [Google Takeout](https://takeout.google.com) and then reupload them on my new account. However, I was soon confronted with the fact that takeout does not provide motion photos in a consistent format:
* Motion photos captured with the **Google** camera are delivered as an image file (JPG) and a video file (MP4). However, the motion photo is completely contained in the image file (with video), hence the video file is completely redundant.
* Live photos captured with an **Apple** iDevice are also delivered as an image file (JPG or HEIC) and a video file (MP4 or MOV) but the image file does not contain the video.

I decided to convert all Apple live photos to Google's motion photo format since that is the only way I know of to retain motion data when uploading them to Google Photos again. (And in general I think self-contained files are more elegant.) Since I didn't find any existing software for this task, I decided to write my own scripts and publish them here in the hope that someone else finds them useful.

> NOTE: This is my first serious foray into Linux scripting and publishing on GitHub so please bare with me here. I'm very open to constructive feedback and/or pull requests.

## The tools
> WARNING: I have tested these tools and they have worked for me, however, I cannot guarantee perfection. As such I recommend using these on a working copy of your pictures. Use at your own risk.

### Filtering redundant Google Motion Photo videos
This simply searches a directory for video files that belong to an existing motion photo and moves the videos to a directory of your choosing. It retains the origin directory structure in the destination.

> NOTE: This script only looks for videos of the same name as a motion photo. So accuracy will not be 100% if you have unrelated videos with the same name as motion photos or if your motion videos have a name different than the motion photo.

#### Dependencies
* [`exiftool`](https://exiftool.org/)

#### Usage
```
filter-red-mopho-vid.sh SEARCH_DIR DESTINATION_DIR
```

`SEARCH_DIR` The directory to be searched and filtered \
`DESTINATION_DIR` The directory to which all identified redundant videos are moved

#### How does it work
It finds all files with XMP tag `MotionPhoto` or `MicroVideo`. For each of these it looks for a video with the same name (excluding the file extension) and moves it to the destination directory. (In some cases the image file has format `*.MP.JPG` and the video file `*.MP`.)

### Filtering Apple Live Photos
This simply searches a directory for image and video files belonging to a live photo and moving them to a directory of your choosing. It retains the origin directory structure in the destination.

#### Dependencies
* [`exiftool`](https://exiftool.org/)

#### Usage
```
filter-live-photos.sh SEARCH_DIR DESTINATION_DIR
```

`SEARCH_DIR` The directory to be searched and filtered \
`DESTINATION_DIR` The directory to which all identified live photos are moved

#### How does it work
It finds all files with XMP tag `MediaGroupUUID` (corresponding to images) or `ContentIdentifier` (corresponding to videos) and moves them to the destination directory.

### Merging Apple Live Photo to Google Motion Photo
This takes live photo image files, looks for a corresponding video and merges them non-destructively to the destination directory. In case the input is a directory, it preserves the directory structure in the destination.

#### Dependencies
* [`exiftool`](https://exiftool.org/)
* [`exiv2`](https://exiv2.org/)
* [ImageMagick](https://imagemagick.org/)

#### Usage
```
merge-live-photo-to-motion-photo.sh INPUT DESTINATION_DIR
```

`INPUT` The location of the live photo to be merged. Can either be a live photo image file or a directory. In case of a directory, the live photos contained in it are merged recursively. \
`DESTINATION_DIR` The directory to which all identified live photos are merged

#### How does it work
It finds all image files with XMP tag `MediaGroupUUID` and looks for a video file with matching `ContentIdentifier`. If the image file is already a JPG, it copies it to the destination, if it is a different format (eg. HEIC), it converts it to a JPG with the same name in the destination. Then it appends the video file to the image file copy. Finally, it writes Google's motion photo XMP tags to the new file (see `exiv2-mopho-xmp.txt`).

## Limitations
This repository currently does not include tools for Motion Photos from Samsung or other vendors since I don't have any such files. If you want to expand/add scripts I'm very open to pull requests. Or if you have such photos and need a tool for it I'm happy to have a look (depending on my availability).

## See also
* [Google Photos Takeout Scripts](https://github.com/m1rkwood/google-photos-takeout-scripts)
* [Working with Motion Photos](https://medium.com/android-news/working-with-motion-photos-da0aa49b50c)