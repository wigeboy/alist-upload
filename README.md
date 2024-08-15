# alist-upload
A shell script to upload files to your Alist drive
name: ' alist upload'
author: 'wigeboy'
description: 'Upload file to your alist driver'
inputs:
  mode:
    description: 'choose tmate or ngrok mode'
    required: false
    default: 'tmate'
  filename:
    description:'which file you want to upload,with file path'
    required: true
    default:''
  alist_url:
    description:'your alist full url,http://url.cn:8000'
    required: true
    default:''
  to_path:
    description:'the alist path you want upload to,/guest/upload'
    required: true
    default:''
runs:
  using: "composite"
  steps: 
    - run: $GITHUB_ACTION_PATH/upload.sh
      shell: bash
branding:
  icon: 'terminal'
  color: 'gray-dark'
