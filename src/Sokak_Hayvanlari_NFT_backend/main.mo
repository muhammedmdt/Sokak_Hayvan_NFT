import Array "mo:base/Array";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Nat8 "mo:base/Nat8";
import Bool "mo:base/Bool";

actor {
    // Sokak hayvanı struct'ı
    type StreetAnimal = {
        id: Nat64;
        name: Text;
        species: Text;
        age: Nat8;
        description: Text;
        image: Text; // Resim URL'si
    };

    // NFT struct'ı
    type NFT = {
        id: Nat64;
        animal_id: Nat64;
        price: Nat64;
        created: Bool; // NFT oluşturuldu mu?
    };

    // Proje struct'ı
    type NFTProject = {
        animals : Array<(Nat64, StreetAnimal)>; // Hayvanların depolandığı array
        nfts : Array<(Nat64, NFT)>; // Oluşturulan NFT'lerin depolandığı array
        total_donation : Nat64; // Toplanan toplam bağış miktarı
    };

    // Hayvan ekleme metodu
    public func add_animal(this : NFTProject, animal : StreetAnimal) : async () {
        this.animals.push((animal.id, animal));
    };

    // NFT oluşturma metodu
    public func create_nft(this : NFTProject, animal_id : Nat64, price : Nat64) : async () {
        var found_animal : ?StreetAnimal = null;
        Array.iter(func((id, animal) : (Nat64, StreetAnimal)) {
            if (id == animal_id) {
                found_animal = some animal;
            }
        }, this.animals);

        switch (found_animal) {
            case null => null;
            case let some_animal => {
                let nft_id = Array.length(this.nfts) + 1;
                let nft : NFT = {
                    id = nft_id;
                    animal_id = animal_id;
                    price = price;
                    created = true;
                };
                this.nfts.push((nft_id, nft));
            };
        }
    };

    // İlgili NFT bilgilerini getirme metodu
    public func get_nft(this : NFTProject, nft_id : Nat64) : async ?NFT {
        let nft = this.nfts.findOpt((func ((_, n) : (Nat64, NFT)) => n.id == nft_id));
        Switch.toOption<NFT>(nft);
    };

    // Tüm NFT'leri getirme metodu
    public func get_all_nfts(this : NFTProject) : async [NFT] {
        Array.map<NFT>(((nft_id, n) : (Nat64, NFT)) => n, this.nfts);
    };

    // NFT satın alma metodu
    public func buy_nft(this : NFTProject, nft_id : Nat64) : async ?Nat64 {
        let nft_index = this.nfts.findIndex((func ((_, n) : (Nat64, NFT)) => n.id == nft_id));
        if (Switch.isSome<Nat>(nft_index)) {
            let some_index = Switch.toSome<Nat>(nft_index);
            let (nft_id, nft) = Array.removeAndGet<this.nfts>(some_index);
            if (nft.created) {
                this.total_donation += nft.price;
                return nft.price;
            };
        };
        null;
    };
};
