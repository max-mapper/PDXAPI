function(doc) {
    emit(doc.geometry || {
        coordinates: [0, 0],
        'type': 'Point'
    },
    {
        id: doc._id,
        geometry: doc.geometry || {
            coordinates: [0, 0],
            'type': 'Point'
        }
    });
};