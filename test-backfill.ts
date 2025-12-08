import fetch from 'node-fetch'

async function testBackfill() {
	try {
		console.log('🔄 Calling backfill endpoint...')
		
		const response = await fetch('http://localhost:3000/strefa-typera/backfill-typy', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
		})

		const data = await response.json()
		
		console.log('\n✅ Response:')
		console.log(JSON.stringify(data, null, 2))
		
		if (data.success) {
			console.log(`\n📊 Summary:`)
			console.log(`   Total rows: ${data.totalRows}`)
			console.log(`   Updated: ${data.rowsUpdated}`)
			console.log(`   Skipped: ${data.rowsSkipped}`)
			console.log(`   Not found: ${data.rowsNotFound}`)
		}
	} catch (error: any) {
		console.error('❌ Error:', error.message)
	}
}

testBackfill()
