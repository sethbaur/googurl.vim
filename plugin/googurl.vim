if !has('python')
    echo 'Error: +python required'
    finish
endif
if !exists('g:googurl_api_key')
    let g:googurl_api_key = ''
endif

map <leader>gu :python googurl()<CR>

python << EOF
import vim
import re
import json
import urllib
import urllib2

def googurl():
    line = vim.current.line
    column = vim.current.window.cursor[1]
    row = vim.current.window.cursor[0]
    matches = re.findall("(?:https?://)?(?:[\w]+\.)(?:\.?[\w]{2,})+", line)
    api_url = 'https://www.googleapis.com/urlshortener/v1/url'
    url = ''
    if matches:
        for match in matches:
            start = line.index(match)
            end = start + len(match)
            if column >= start and column < end:
                url = match

    if url:
        data = json.dumps({'longUrl':url})
        if vim.eval('g:googurl_api_key'):
            api_url += '?key='+vim.eval('g:googurl_api_key')
        req = urllib2.Request(api_url, data, {'Content-Type':'application/json'})
        res = urllib2.urlopen(req)
        new_data = json.loads(res.read())
        if 'id' in new_data:
            short_url = str(new_data['id']).replace('/','\/')
            vim.command(':'+str(row)+'s/'+url.replace('/','\/')+'/'+short_url+'/g')
            vim.command(':noh')
            print new_data['id']
    else:
        print 'no url'

EOF
