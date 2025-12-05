/**
 * Test adding match to Strefa Typera
 */

async function testAddMatch() {
	try {
		console.log('🧪 Testing Strefa Typera API...\n')

		const response = await fetch('http://localhost:3000/api/strefa-typera/add-match', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({
				homeTeam: 'Manchester United',
				awayTeam: 'Liverpool',
			}),
		})

		const result = await response.json()

		if (response.ok) {
			console.log('✅ Success!')
			console.log(`   Row: ${result.row}`)
			console.log(`   Home: ${result.homeTeam}`)
			console.log(`   Away: ${result.awayTeam}`)
			console.log(`   Message: ${result.message}`)
		} else {
			console.error('❌ Error:', result.error)
		}
	} catch (error) {
		console.error('❌ Test failed:', error)
	}
}

testAddMatch()
